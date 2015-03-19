require 'spec_helper'

describe BuildNotes do
  let(:launcher) { double(:launcher) }
  let(:listener) { double(:listener, :info => true) }
  let(:native) do
    double(
      :getBuiltOnStr => 'master',
      :getTimeInMillis => Time.now.to_i * 1000,
      :getFullDisplayName => 'project-master #951',
      :getId => '2012-04-10_20-52-03',
      :getNumber => '951',
      :getResult => double(:toString => 'SUCCESS'),
      :getBuildStatusSummary => double(:message => 'stable'),
      :getUrl => 'job/project-master/951'
    )
  end
  let(:build) { double(:send => native) }
  let(:context) { BuildContext.new(build, launcher, listener) }

  subject { BuildNotes.new(context) }

  describe '.notes' do
    it 'returns a jenkins build note' do
      expect(subject.notes).to_not be_nil
    end
  end
end
