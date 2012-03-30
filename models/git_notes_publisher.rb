require 'stringio'

class GitNotesPublisher < Jenkins::Tasks::Publisher
  GIT_NOTES_REF = "jenkins"

  display_name "Publish build result as git-notes"

  def initialize(attrs = {})
  end

  ##
  # Runs before the build begins
  #
  # @param [Jenkins::Model::Build] build the build which will begin
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def prebuild(build, listener)
  end

  ##
  # Runs the step over the given build and reports the progress to the listener.
  #
  # @param [Jenkins::Model::Build] build on which to run this step
  # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def perform(build, launcher, listener)
    # show existing notes
    bx = build_exec(build, listener, "git notes --ref #{GIT_NOTES_REF} show")
    if bx[:val] == 0
      existing_notes = bx[:out].strip
      listener.info "git-notes plugin: existing notes: #{existing_notes}"
    end

    # create new notes
    native = build.send(:native)
    built_on = native.getBuiltOnStr || "master"
    built_on = "master" if built_on.empty?
    time = Time.at(native.getTimeInMillis / 1000.0)
    duration = Time.now - time
    notes_hash = {
        :built_on => built_on,
        :duration => duration,
        :full_display_name => native.getFullDisplayName,
        :id => native.getId,
        :number => native.getNumber,
        :result => native.getResult.toString,
        :status_message => native.getBuildStatusSummary.message,
        :time => time,
        :url => native.getUrl
    }
    notes_json = JSON.pretty_generate(notes_hash)
    listener.info "git-notes plugin: notes json: #{notes_json}"

    # add and push new notes
    build_exec(build, listener, "git notes --ref #{GIT_NOTES_REF} add -f -F -", {:stdin_str => notes_json, :raise => true})
    listener.info "git-notes plugin: added notes"
    build_exec(build, listener, "git push origin refs/notes/#{GIT_NOTES_REF} -f", {:raise => true})
    listener.info "git-notes plugin: pushed notes"
  end

  # Execute a command for the given build, log to listener, return hash with :out, :err, :val.
  def build_exec(build, listener, command, opts = {})
    listener.info("git-notes-plugin: build_exec: command: #{command.inspect}, opts: #{opts.inspect}")
    opts[:out] ||= StringIO.new
    opts[:err] ||= StringIO.new
    if stdin_str = opts.delete(:stdin_str)
      stdin = StringIO.new
      stdin.puts stdin_str
      stdin.rewind
      opts[:in] = stdin
    end
    launcher = build.workspace.create_launcher(listener)
    val = launcher.execute(command, opts)
    opts[:out].rewind
    opts[:err].rewind
    result = {:out => opts[:out].read, :err => opts[:err].read, :val => val}
    if opts[:raise] && val != 0
      raise "Unexpected exit code (#{val}): command: #{command.inspect}: result: #{result.inspect}"
    end
    listener.info("git-notes-plugin: build_exec: returning: #{result.inspect}")
    result
  end
  private :build_exec
end