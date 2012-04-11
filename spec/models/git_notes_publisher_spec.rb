require 'spec_helper'

describe GitNotesPublisher do
  context 'the git notes publisher' do
    let(:build) { stub }
    let(:launcher) { stub }
    let(:listener) { stub(:info => true) }
    let(:git_note) { stub }
    let(:git_note_hash) do
      {
        :foo => :bar,
        :biz => :baz
      }
    end

    context '.perform' do
      before do
        GitNote.stub(:new).and_return(git_note)
      end

      it 'updates a note once when it succeeds' do
        git_note.should_receive(:update!).with(git_note_hash).and_return(true)
        subject.stub(:build_note_hash).and_return(git_note_hash)

        subject.perform(build, launcher, listener)
      end

      it 'tries to update a note three times in the case of failure' do
        git_note.should_receive(:update!).with(git_note_hash).exactly(3).times.and_return(false)
        subject.stub(:build_note_hash).and_return(git_note_hash)

        subject.perform(build, launcher, listener)
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
