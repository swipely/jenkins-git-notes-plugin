require 'fog'

# This class handles sending messages to an SQS queue.
class SqsNotifier
  include BuildParticipant

  attr_reader :queue_url, :creds, :build_context

  # Create anew SqsNotifier with the given queue_url and credentials.
  def initialize(build_context, queue_url, creds)
    @build_context = build_context
    @queue_url = queue_url
    @creds = creds
  end

  # Send a git note notification. This method will fail if the origin url cannot
  # be read, the sha cannot be read, or if the queue does not exist.
  def notify_note(note)
    repo = run("git config --get remote.origin.url", raise: true)[:out].chomp
    info = run("git show HEAD", raise: true)[:out]
    sha  = info.lines.first.chomp.split(' ')[1]
    notify(JSON.pretty_generate(repo: repo, sha: sha, source: 'jenkins', note: note))
    nil
  end

  private

  def notify(message)
    sqs.send_message(queue_url, message)
  end

  def sqs
    @sqs ||= Fog::AWS::SQS.new(creds)
  end
end
