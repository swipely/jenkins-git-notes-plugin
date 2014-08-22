require 'spec_helper'

describe BuildContext do
  subject { BuildContext.instance }

  let(:build) { double(:build) }
  let(:launcher) { double(:launcher) }
  let(:listener) { double(:listener) }

  before do
    subject.unset
  end

  after do
    subject.unset
  end

  context '.set' do
    it 'sets the attributes' do
      subject.set(build, launcher, listener)
      expect(subject.build).to eq(build)
      expect(subject.launcher).to eq(launcher)
      expect(subject.listener).to eq(listener)
    end

    it 'temporarily sets the attributes when passed a block' do
      subject.set(build, launcher, listener) do
        expect(subject.build).to eq(build)
        expect(subject.launcher).to eq(launcher)
        expect(subject.listener).to eq(listener)
      end
      expect(subject.build).to be_nil
      expect(subject.launcher).to be_nil
      expect(subject.listener).to be_nil
    end
  end

  context '.unset' do
    it 'unsets any previously set attributes' do
      subject.set(build, launcher, listener)
      subject.unset
      expect(subject.build).to be_nil
      expect(subject.launcher).to be_nil
      expect(subject.listener).to be_nil
    end
  end
end
