require 'spec_helper'

describe GitNotesPublisher do
  context 'the git notes publisher' do
    let(:build) { stub }
    let(:launcher) { stub }
    let(:listener) { stub(:info => true) }
    let(:git_updater) { stub }

    before do
      BuildNotes.stub(:new => stub(:notes => {}))
      BuildContext.instance.set(build, launcher, listener)
    end

    after do
      BuildContext.instance.unset
    end

    context '.perform' do
      before do
        GitUpdater.stub(:new).and_return(git_updater)
      end

      it 'updates a note once when it succeeds' do
        git_updater.should_receive(:update!).and_return(true)
        subject.perform(build, launcher, listener)
      end

      it 'tries to update a note three times in the case of failure' do
        git_updater.should_receive(:update!).exactly(3).times.and_raise(GitUpdater::ConcurrentUpdateError)
        listener.should_receive(:warn).exactly(2).times
        lambda { subject.perform(build, launcher, listener) }.should raise_error(GitUpdater::ConcurrentUpdateError)
      end
    end
  end
end
