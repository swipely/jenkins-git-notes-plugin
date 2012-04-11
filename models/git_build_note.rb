class GitBuildNote
  attr_reader :refname, :exec, :build, :listener

  def initialize(refname, build, listener)
    @refname = refname
    @build = build
    @listener = listener
    @exec = BuildExec.new(build, listener)
  end

  # Attach a git note based on the build status and push it to origin
  def update!
    fetch_refs
    listener.info "git-notes plugin: fetched note refs"

    existing_note = get_existing
    listener.info "git-notes plugin: existing note: #{existing_note}"

    note_hash = build_hash(existing_note)
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

  # Return a hash representing the git note we want to add to HEAD
  def build_hash(existing)
    native = build.send(:native)
    built_on = native.getBuiltOnStr || "master"
    built_on = "master" if built_on.empty?
    time = Time.at(native.getTimeInMillis / 1000.0)
    duration = Time.now - time

    ret = {
      :built_on => built_on,
      :duration => duration,
      :full_display_name => native.getFullDisplayName,
      :id => native.getId,
      :number => native.getNumber,
      :result => native.getResult.toString,
      :status_message => native.getBuildStatusSummary.message,
      :time => time,
      :url => native.getUrl
    }

    ret[:previous_note] = JSON.parse(existing) if existing

    ret
  end
end
