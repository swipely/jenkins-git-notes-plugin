require 'spec_helper'

describe GitUpdater do
  context 'a build note' do
    let(:listener) { stub(:info => true) }
    let(:launcher) { stub }
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
    let(:workspace) do
      stub({
        :realpath => '/var/jenkins/builds'
      })
    end
    let(:build) { stub(:send => native, :workspace => workspace) }

    subject { GitUpdater.new }

    before do
      BuildContext.instance.set(build, launcher, listener)
    end

    after do
      BuildContext.instance.unset
    end

    context '.fetch_notes' do
      it 'executes a command to fetch the latest notes' do
        subject.should_receive(:run)
        subject.fetch_notes
      end
    end

    context '.show_notes' do
      it 'logs appropriately when there is an existing note' do
        subject.should_receive(:run).and_return({:val => 0, :out => 'existing note'})
        subject.should_receive(:info)
        subject.should_receive(:info).with('existing note: existing note')
        subject.show_notes
      end
      
      it 'logs appropriately when there is no existing note' do
        subject.should_receive(:run).and_return({:val => 1, :out => 'an error'})
        subject.should_receive(:info)
        subject.should_receive(:info).with('no existing note')
        subject.show_notes
      end
    end

    context '.push_notes' do
      it 'adds and pushes the note' do
        subject.should_receive(:run).twice.and_return({:val => 0})
        subject.push_notes("a note")
      end

      it 'does not raise when push succeeds' do
        subject.stub(:run => {:val => 0, :out => ''})
        lambda { subject.push_notes("a note") }.should_not raise_error
      end

      it 'raises when push fails' do
        subject.stub(:run => {:val => 1})
        lambda { subject.push_notes("a note") }.should raise_error GitUpdater::ConcurrentUpdateError
      end
    end
  end
end
