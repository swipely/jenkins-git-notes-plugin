require File.expand_path('../../lib/constants', __FILE__)
require File.expand_path('../../lib/build_context', __FILE__)
require File.expand_path('../../lib/build_participant', __FILE__)
require File.expand_path('../../lib/build_notes', __FILE__)
require File.expand_path('../../lib/git_updater', __FILE__)

class GitNotesPublisher < Jenkins::Tasks::Publisher
  include BuildParticipant

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
    BuildContext.instance.set(build, launcher, listener) do
      git_updater = GitUpdater.new
      retries = Constants::CONCURRENT_UPDATE_RETRIES
      notes = BuildNotes.new.notes
      begin
        info "updating git notes"
        git_updater.update!(notes)
      rescue GitUpdater::ConcurrentUpdateError => e
        if retries > 0
          warn "caught ConcurrentUpdateError while updating git notes, retrying (#{retries}x left)"
          retries -= 1
          retry
        else
          raise e
        end
      end
      info "updated git notes: #{notes}"
    end
  end
end
