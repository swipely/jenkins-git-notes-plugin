require File.expand_path('../../lib/constants', __FILE__)
require File.expand_path('../../lib/build_context', __FILE__)
require File.expand_path('../../lib/build_participant', __FILE__)
require File.expand_path('../../lib/build_notes', __FILE__)
require File.expand_path('../../lib/git_updater', __FILE__)
require File.expand_path('../../lib/sqs_notifier', __FILE__)

class GitNotesPublisher < Jenkins::Tasks::Publisher
  display_name "Publish build result as git-notes"

  attr_reader :sqs_queue, :access_key, :secret_key

  def initialize(attrs = {})
    @sqs_queue, @access_key, @secret_key =
      attrs.values_at(*%w(sqs_queue access_key secret_key))
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
    context = BuildContext.new(build, launcher, listener)
    notes = BuildNotes.new(context).notes
    update_git_notes(notes, context)
    notify_sqs(notes, context)
  end

  private

  def update_git_notes(notes, context)
    git_updater = GitUpdater.new(context)
    retry_times = Constants::CONCURRENT_UPDATE_SLEEP_TIMES
    retry_times.each_with_index do |retry_time, idx|
      begin
        context.listener.info "updating git notes"
        git_updater.update!(notes)
        break
      rescue GitUpdater::ConcurrentUpdateError => ex
        retries = retry_times.length.pred - idx
        raise ex if retries.zero?
        context.listener.warn "caught ConcurrentUpdateError while updating git notes, retrying (#{retries}x left)"
        sleep(retry_time)
      end
    end

    context.listener.info "updated git notes: #{notes}"
  end

  def notify_sqs(notes, context)
    queue = SqsNotifier.new(context, sqs_queue, aws_access_key_id: access_key, aws_secret_access_key: secret_key)
    queue.notify_note(notes) if sqs_configured?
  end

  def sqs_configured?
    [sqs_queue, access_key, secret_key].all? do |i|
      !i.nil? && !i.strip.empty?
    end
  end
end
