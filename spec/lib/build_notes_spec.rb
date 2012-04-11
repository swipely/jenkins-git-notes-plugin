require 'spec_helper'

describe BuildNotes do
  let(:launcher) { stub }
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

  before do
    BuildContext.instance.set(build, launcher, listener)
  end

  after do
    BuildContext.instance.unset
  end

  context '.notes' do
    it 'returns a jenkins build note' do
      subject.notes.should_not be_nil
    end
  end
end
