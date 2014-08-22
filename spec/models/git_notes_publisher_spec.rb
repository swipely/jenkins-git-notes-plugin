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
  end
end
