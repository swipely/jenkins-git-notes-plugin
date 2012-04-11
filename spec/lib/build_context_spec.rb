require 'spec_helper'

describe BuildContext do
  subject { BuildContext.instance }

  let(:build) { stub }
  let(:launcher) { stub }
  let(:listener) { stub }

  before do
    subject.unset
  end

  after do
    subject.unset
  end

  context '.set' do
    it 'sets the attributes' do
      subject.set(build, launcher, listener)
      subject.build.should == build
      subject.launcher == launcher
      subject.listener == listener
    end

    it 'temporarily sets the attributes when passed a block' do
      subject.set(build, launcher, listener) do
        subject.build.should == build
        subject.launcher == launcher
        subject.listener == listener
      end
      subject.build.should be_nil
      subject.launcher.should be_nil
      subject.listener.should be_nil
    end
  end

  context '.unset' do
    it 'unsets any previously set attributes' do
      subject.set(build, launcher, listener)
      subject.unset
      subject.build.should be_nil
      subject.launcher.should be_nil
      subject.listener.should be_nil
    end
  end
end
