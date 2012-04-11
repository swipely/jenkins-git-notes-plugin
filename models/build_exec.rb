class BuildExec
  attr_reader :build, :listener

  def initialize(build, listener)
    @build = build
    @listener = listener
  end

  # Execute a command for the given build, log to listener, return hash with :out, :err, :val.
  def run(command, opts = {})
    listener.info("git-notes-plugin: build_exec: command: #{command.inspect}, opts: #{opts.inspect}")

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
    launcher = build.workspace.create_launcher(listener)
    val = launcher.execute(command, opts)
    opts[:out].rewind
    opts[:err].rewind
    result = {:out => opts[:out].read, :err => opts[:err].read, :val => val}

    raise "Unexpected exit code (#{val}): command: #{command.inspect}: result: #{result.inspect}" if opts[:raise] && 0 != val

    listener.info("git-notes-plugin: build_exec: returning: #{result.inspect}")
    result
  end
end
