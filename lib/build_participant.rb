require 'stringio'
require 'forwardable'

# This mixin provides utilities for interacting with a build context. Including
# classes/modules must provide a `#build_context` method, which returns a
# reference to the build context.
module BuildParticipant
  extend Forwardable

  def_delegators :build_context, :build, :launcher, :listener

  def debug(line)
    listener.debug(format(line))
  end

  def error(line)
    listener.error(format(line))
  end

  def fatal(line)
    listener.fatal(format(line))
  end

  def info(line)
    listener.info(format(line))
  end

  def warn(line)
    listener.warn(format(line))
  end

  def run(command, opts = {})
    info "running command #{command.inspect} with opts #{opts.inspect}"

    default_dir = build.workspace.realpath

    native = build.send(:native)
    env = native.getEnvironment
    if env.has_key?('GIT_LOCAL_SUBDIRECTORY')
      default_dir += '/' + env['GIT_LOCAL_SUBDIRECTORY']
    end

    # Set the repo directory and process streams
    opts[:chdir] ||= default_dir
    opts[:out] ||= StringIO.new
    opts[:err] ||= StringIO.new
    if stdin_str = opts.delete(:stdin_str)
      stdin = StringIO.new
      stdin.puts stdin_str
      stdin.rewind
      opts[:in] = stdin
    end

    # Execute the command and save the output
    val = launcher.execute(command, opts)
    opts[:out].rewind
    opts[:err].rewind
    result = {:out => opts[:out].read, :err => opts[:err].read, :val => val}

    raise "Unexpected exit code (#{val}): command: #{command.inspect}: result: #{result.inspect}" if opts[:raise] && 0 != val

    info "returning results of run: #{result.inspect}"
    result
  end

  def format(line)
    "#{Constants::LOG_PREFIX}#{line}"
  end
  private :format
end
