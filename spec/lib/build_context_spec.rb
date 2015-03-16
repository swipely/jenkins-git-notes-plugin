require 'spec_helper'

describe BuildContext do
  let(:build) { double(:build) }
  let(:launcher) { double(:launcher) }
  let(:listener) { double(:listener) }

  subject { BuildContext.new(build, launcher, listener) }

  describe '#initialize' do
    it 'sets the build, launcher, and listener' do
      expect(subject.build).to eq(build)
      expect(subject.launcher).to eq(launcher)
      expect(subject.listener).to eq(listener)
    end
  end
end
