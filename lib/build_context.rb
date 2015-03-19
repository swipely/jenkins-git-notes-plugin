class BuildContext
  attr_reader :build, :launcher, :listener

  def initialize(build, launcher, listener, &block)
    @build = build
    @launcher = launcher
    @listener = listener
  end
end
