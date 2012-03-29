require 'grit'

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
      repo = Grit::Repo.new(build.workspace.realpath)
      existing_notes = repo.git.native(:notes, {:ref => GIT_NOTES_REF}, :show).strip
      listener.info "git-notes plugin: existing notes: #{existing_notes}"

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
      repo.git.native(:notes, {:raise => true, :ref => GIT_NOTES_REF}, :add, "-f", "-m", notes_json)
      listener.info "git-notes plugin: added notes"
      repo.git.native(:push, {:raise => true}, "origin", "refs/notes/#{GIT_NOTES_REF}", "-f")
      listener.info "git-notes plugin: pushed notes"
    end
end