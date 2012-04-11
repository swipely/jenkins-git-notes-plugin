PROJECT_ROOT = File.expand_path("../..", __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, "models")

ENV["RAILS_ENV"] = 'test'

# System deps
require 'json'

# Needed so we can run the unit tests independently of Jenkins
module Jenkins
  module Tasks
    class Publisher
      def self.display_name(str) ; end
    end
  end
end

# Classes defined in this plugin
require 'build_exec'
require 'git_build_note'
require 'git_notes_publisher'
