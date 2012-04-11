class GitNotesPublisher < Jenkins::Tasks::Publisher
  GIT_NOTES_REF = "jenkins"

  display_name "Publish build result as git-notes"

  def initialize(attrs = {})
  end

  ##
  # Runs before the build begins
  #
  # @param [Jenkins::Model::Build] build the build which will begin
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def prebuild(build, listener)
  end

  ##
  # Runs the step over the given build and reports the progress to the listener.
  #
  # @param [Jenkins::Model::Build] build on which to run this step
  # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def perform(build, launcher, listener)
    git_note = GitBuildNote.new(GIT_NOTES_REF, build, listener)

    tries = 3
    while tries > 0 && !git_note.update!
      tries -= 1
    end
  end
end
