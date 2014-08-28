require 'spec_helper'

describe SqsNotifier do
  subject { SqsNotifier.new('my-test-queue', {}) }

  describe '#notify_note' do
    let(:remote_command) { "git config --get remote.origin.url" }
    let(:sha_command) { "git show HEAD" }

    let(:note) { { test: 'note' } }
    let(:client) { double(:client) }

    before { subject.stub(:sqs).and_return(client) }

    context 'when the remote url cannot be found' do
      before { subject.stub(:run).with(remote_command, raise: true).and_raise }

      it 'raises an error' do
        expect { subject.notify_note(note) }.to raise_error
      end
    end

    context 'when the remote url can be found' do
      let(:url) { 'git@github.com:swipely/jenkins-git-notes-plugin' }
      before do
        subject.stub(:run).with(remote_command, raise: true)
            .and_return(out: url)
      end

      context 'but the current sha cannot be found' do
        before do
          subject.stub(:run).with(remote_command, raise: true).and_raise
        end

        it 'raises an error' do
          expect { subject.notify_note(note) }.to raise_error
        end
      end

      context 'and the current sha can be found' do
        let(:sha) { 5.times.map { 'deadbeef' }.join }
        before do
          subject.stub(:run).with(sha_command, raise: true)
                 .and_return(out: "commit #{sha}\n")
        end

        context 'but the queue does not exist' do
          before { client.stub(:send_message).and_raise }

          it 'raises an error' do
            expect { subject.notify_note(note) }.to raise_error
          end
        end

        context 'and the queue does exists' do
          let(:message) {
            JSON.pretty_generate(
              repo: url,
              sha: sha,
              source: 'jenkins',
              note: note
            )
          }

          it 'sends the notification' do
            expect(client).to receive(:send_message).with('my-test-queue', message)

            expect { subject.notify_note(note) }.to_not raise_error
          end
        end
      end
    end
  end
end
