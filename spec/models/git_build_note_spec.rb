require 'spec_helper'

describe GitBuildNote do
  context 'a build note' do
    let(:listener) { stub(:info => true) }
    let(:native) do
      stub({
        :getBuiltOnStr => 'master',
        :getTimeInMillis => Time.now.to_i * 1000,
        :getFullDisplayName => 'project-master #951',
        :getId => '2012-04-10_20-52-03',
        :getNumber => '951',
        :getResult => stub(:toString => 'SUCCESS'),
        :getBuildStatusSummary => stub(:message => 'stable'),
        :getUrl => 'job/project-master/951'
      })
    end
    let(:build) { stub(:send => native) }

    subject { GitBuildNote.new('jenkins', build, listener) }

    context '.update!' do
      let(:json) do
        {'hello' => 'world'}.to_json
      end

      it 'returns true when attach succeeds' do
        result = stub(:run => {:val => 0, :out => json})
        subject.stub(:exec).and_return(result)
        subject.update!.should be_true
      end

      it 'returns false when attach fails' do
        result = stub(:run => {:val => 1})
        subject.stub(:exec).and_return(result)
        subject.update!.should be_false
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

    context '.build_hash' do
      it 'returns a jenkins build note without an existing note' do
        subject.build_hash(nil).should_not be_nil
        subject.build_hash(nil)[:previous_note].should be_nil
      end

      it 'returns a jenkins build note with an existing note' do
        subject.build_hash({'hello' => 'world'}.to_json).should_not be_nil
        subject.build_hash({'hello' => 'world'}.to_json)[:previous_note].should == {'hello' => 'world'}
      end
    end

  end
end
