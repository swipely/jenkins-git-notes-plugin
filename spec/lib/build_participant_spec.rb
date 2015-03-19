require 'spec_helper'

describe BuildParticipant do
  context 'a build executor' do
    let(:listener) { double(:info => true) }
    let(:launcher) { double(:execute) }
    let(:workspace) do
      double(:realpath => '/var/jenkins/builds')
    end
    let(:build) { double(:workspace => workspace) }
    let(:context) { BuildContext.new(build, launcher, listener) }
    let(:test_class) {
      Class.new do
        include BuildParticipant

        attr_reader :build_context

        def initialize(build_context)
          @build_context = build_context
        end
      end
    }

    subject { test_class.new(context) }

    context '.build' do
      it 'returns the build set in the context singleton' do
        subject.build == build
      end
    end

    context '.listener' do
      it 'returns the listener set in the context singleton' do
        subject.listener == listener
      end
    end

    context '.launcher' do
      it 'returns the launcher set in the context singleton' do
        subject.launcher == launcher
      end
    end

    context '.run' do
      let(:out) { StringIO.new << "stdout" }
      let(:err) { StringIO.new << "stderr" }

      before do
        expect(launcher).to receive(:execute).and_return(1)
      end

      it 'succeeds with no opts' do
        expect(subject.run('foo')).to eq(:out => '', :err => '', :val => 1)
      end

      it 'returns the stdout, stderr, and exit code from the command that was run' do
        opts = {:out => out, :err => err}
        expect(subject.run('foo', opts)).to eq(:out => 'stdout', :err => 'stderr', :val => 1)
      end

      it 'assigns the contents of opts[:stdin_str] to a stream in opts[:in]' do
        opts = {:out => out, :err => err, :stdin_str => "More STDIN"}
        subject.run('foo', opts)

        expect(opts[:in].read).to eq("More STDIN\n")
      end

      it 'raises an exception when opts[:raise] is provided and the command fails' do
        expect { subject.run('foo', {:raise => true}) }.to raise_error(StandardError)
      end
    end
  end
end
