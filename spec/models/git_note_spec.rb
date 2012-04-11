require 'spec_helper'

describe GitNote do
  context 'a build note' do
    let(:listener) { stub(:info => true) }
    let(:exec) { stub }
    let(:build_note) do
      {
        :foo => :bar,
        :biz => :baz
      }
    end

    subject { GitNote.new('jenkins', exec, listener) }

    context '.update!' do
      let(:json) do
        {'hello' => 'world'}.to_json
      end

      it 'parses an existing note when one is present' do
        result = {:val => 0, :out => json}
        subject.stub(:get_existing).and_return({'hello' => 'world'}.to_json)
        subject.exec.stub(:run).and_return(result)

        JSON.should_receive(:parse).with(json)
        subject.update!(build_note).should be_true
      end

      it 'returns true when attach succeeds' do
        result = {:val => 0, :out => json}
        subject.exec.stub(:run).and_return(result)
        subject.update!(build_note).should be_true
      end

      it 'returns false when attach fails' do
        result = {:val => 1}
        subject.exec.stub(:run).and_return(result)
        subject.update!(build_note).should be_false
      end
    end

    context '.fetch_refs' do
      it 'executes a command to fetch the latest refs' do
        subject.exec.should_receive(:run)
        subject.fetch_refs
      end
    end

    context '.get_existing' do
      it 'returns the value printed to STDOUT on success' do
        subject.exec.should_receive(:run).and_return({:val => 0, :out => 'existing note'})
        subject.get_existing.should == 'existing note'
      end
      
      it 'returns nil on failure' do
        subject.exec.should_receive(:run).and_return({:val => 1, :out => 'existing note'})
        subject.get_existing.should be_nil
      end
    end

    context '.attach' do
      it 'adds and pushes the note' do
        subject.exec.should_receive(:run).twice
        subject.attach({'hello' => 'world'})
      end
    end

  end
end
