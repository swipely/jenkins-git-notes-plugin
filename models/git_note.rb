class GitNote
  attr_reader :refname, :exec, :listener

  def initialize(refname, exec, listener)
    @refname = refname
    @exec = exec
    @listener = listener
  end

  # Attach a git note based on the build status and push it to origin
  def update!(note_hash)
    note_hash = note_hash.dup

    fetch_refs
    listener.info "git-notes plugin: fetched note refs"

    existing_note = get_existing
    listener.info "git-notes plugin: existing note: #{existing_note}"

    note_hash[:previous_note] = JSON.parse(existing_note) if existing_note
    listener.info "git-notes plugin: note to add: #{note_hash.inspect}"

    res = attach(note_hash)
    listener.info "git-notes plugin: attached note: #{res[:val]}"

    0 == res[:val]
  end

  # Force-update the notes ref to get changes from other workers
  def fetch_refs
    exec.run("git fetch -f origin refs/notes/#{refname}:refs/notes/#{refname}", {:raise => true})
  end

  # Return the contents of any existing git note on HEAD, or nil if none
  def get_existing
    res = exec.run("git notes --ref #{refname} show", {:raise => true})
    res[:out].strip if 0 == res[:val]
  end

  # Add the git note and push it to origin
  def attach(note_hash)
    exec.run("git notes --ref #{refname} add -f -F -", {:stdin_str => JSON.pretty_generate(note_hash), :raise => true})
    exec.run("git push origin refs/notes/#{refname}")
  end
end
