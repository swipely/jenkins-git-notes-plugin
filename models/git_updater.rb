class GitUpdater
  include Builder

  attr_reader :notes

  def refname
    Constants::GIT_NOTES_REF
  end

  # Attach a git note based on the build status and push it to origin
  def update!
    fetch_notes
    show_notes
    generate_notes
    push_notes
  end

  # Force-update the notes ref to get changes from other builds
  def fetch_notes
    info "fetching notes"
    run("git fetch -f origin refs/notes/#{refname}:refs/notes/#{refname}", {:raise => true})
  end

  # Log any existing git notes
  def show_notes
    info "showing notes"
    res = run("git notes --ref #{refname} show")
    if res[:val] == 0
      info "existing note: #{res[:out].strip}"
    else
      info "no existing note"
    end
  end

  def generate_notes
    info "generating notes"
    @notes = NotesGenerator.new.notes
    info "new notes: #{notes}"
  end

  # Add the git note and push it to origin
  def push_notes
    run("git notes --ref #{refname} add -f -F -", {:stdin_str => notes, :raise => true})
    begin
      run("git push origin refs/notes/#{refname}", {:raise => true})
    rescue RuntimeError => e
      raise(ConcurrentUpdateError, "trouble pushing notes: #{e.inspect}", e.backtrace)
    end
  end
end
