class GitUpdater
  class ConcurrentUpdateError < RuntimeError ; end

  include BuildParticipant

  def refname
    Constants::GIT_NOTES_REF
  end

  # Attach a git note based on the build status and push it to origin
  def update!(notes)
    fetch_notes
    show_notes
    push_notes(notes)
  end

  # Force-update the notes ref to get changes from other builds
  def fetch_notes
    info "fetching notes"
    run("git fetch -f origin refs/notes/*:refs/notes/*", {:raise => true})
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

  # Add the git note and push it to origin
  def push_notes(notes)
    run("git notes --ref #{refname} add -f -F -", {:stdin_str => notes, :raise => true})
    ret = run("git push origin refs/notes/#{refname}")
    raise(ConcurrentUpdateError, "trouble pushing notes") unless ret[:val] == 0
  end
end
