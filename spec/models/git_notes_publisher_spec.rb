require 'spec_helper'

describe GitNotesPublisher do
  context 'the git notes publisher' do
    let(:build) { double(:build) }
    let(:launcher) { double(:launcher) }
    let(:listener) { double(:listener, :info => true) }
    let(:git_updater) { double(:git_updater) }

    before do
      BuildNotes.stub(:new => double(:notes => {}))
      BuildContext.instance.set(build, launcher, listener)
    end

    after do
      BuildContext.instance.unset
    end

    context '.perform' do
      before do
        GitUpdater.stub(:new).and_return(git_updater)
        subject.stub(:sleep)
      end

      it 'updates a note once when it succeeds' do
        expect(git_updater).to receive(:update!).and_return(true)
        subject.perform(build, launcher, listener)
      end

      it 'tries to update a note eight times in the case of failure' do
        expect(git_updater).to receive(:update!).exactly(8).times.and_raise(GitUpdater::ConcurrentUpdateError)
        expect(listener).to receive(:warn).exactly(7).times
        expect { subject.perform(build, launcher, listener) }.to raise_error(GitUpdater::ConcurrentUpdateError)
      end
    end

    context '.sqs_configured?' do
      let(:access_key) { 'b' }
      let(:secret_key) { 'c' }

      before do
        allow(subject).to receive(:sqs_queue).and_return(sqs_queue)
        allow(subject).to receive(:access_key).and_return(access_key)
        allow(subject).to receive(:secret_key).and_return(secret_key)
      end

      context 'when one is nil' do
        let(:sqs_queue) { nil }

        it 'should be false' do
          expect(subject.send(:sqs_configured?)).to be_falsy
        end
      end

      context 'when one is empty string' do
        let(:sqs_queue) { '' }

        it 'should be false' do
          expect(subject.send(:sqs_configured?)).to be_falsy
        end
      end

      context 'when all are valid' do
        let(:sqs_queue) { 'a' }

        it 'should be true' do
          expect(subject.send(:sqs_configured?)).to be_truthy
        end
      end
    end
  end
end
