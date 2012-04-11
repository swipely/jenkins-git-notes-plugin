require 'singleton'

class BuildContext
  include Singleton

  attr_reader :build, :launcher, :listener

  def set(build, launcher, listener, &block)
    @build = build
    @launcher = launcher
    @listener = listener
    if block_given?
      begin
        block.call
      ensure
        unset
      end
    end
  end

  def unset
    @build = @launcher = @listener = nil
  end
end
