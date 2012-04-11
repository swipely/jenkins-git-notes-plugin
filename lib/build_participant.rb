require 'stringio'

module BuildParticipant
  def build
    BuildContext.instance.build
  end

  def launcher
    BuildContext.instance.launcher
  end

  def listener
    BuildContext.instance.listener
  end

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

    # Set the repo directory and process streams
    opts[:chdir] ||= build.workspace.realpath
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