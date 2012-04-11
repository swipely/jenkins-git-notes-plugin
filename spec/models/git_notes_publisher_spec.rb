require 'spec_helper'

describe GitNotesPublisher do
  context 'the git notes publisher' do
    let(:build) { stub }
    let(:launcher) { stub }
    let(:listener) { stub(:info => true) }
    let(:git_updater) { stub }

    before do
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
        git_updater.should_receive(:update!).exactly(3).times.and_raise(ConcurrentUpdateError)
        listener.should_receive(:warn).exactly(2).times
        lambda { subject.perform(build, launcher, listener) }.should raise_error(ConcurrentUpdateError)
      end
    end
    
    context '.build_note_hash' do
      let(:time) { Time.now }
      let(:native) do
        stub({
          :getBuiltOnStr => 'master',
          :getTimeInMillis => time.to_i * 1000,
          :getFullDisplayName => 'project-master #951',
          :getId => '2012-04-10_20-52-03',
          :getNumber => '951',
          :getResult => stub(:toString => 'SUCCESS'),
          :getBuildStatusSummary => stub(:message => 'stable'),
          :getUrl => 'job/project-master/951'
        })
      end
      let(:build) { stub(:send => native) }

      it 'returns a jenkins build note' do
        subject.send(:build_note_hash, build).should_not be_nil
      end
    end

  end
end
