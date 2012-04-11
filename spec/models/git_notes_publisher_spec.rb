require 'spec_helper'

describe GitNotesPublisher do
  context 'the git notes publisher' do
    let(:build) { stub }
    let(:launcher) { stub }
    let(:listener) { stub(:info => true) }
    let(:git_note) { stub }

    context '.perform' do
      before do
        GitBuildNote.stub(:new).and_return(git_note)
      end

      it 'updates a note once when it succeeds' do
        git_note.should_receive(:update!).and_return(true)
        subject.perform(build, launcher, listener)
      end

      it 'tries to update a note three times in the case of failure' do
        git_note.should_receive(:update!).exactly(3).times.and_return(false)
        subject.perform(build, launcher, listener)
      end
    end
  end
end
