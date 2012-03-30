Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = "git-notes"
  plugin.display_name = "git-notes Plugin"
  plugin.version = '0.0.2'
  plugin.description = 'Add git-notes with Jenkins build status!'

  plugin.url = 'https://wiki.jenkins-ci.org/display/JENKINS/git-notes+Plugin'

  plugin.developed_by "bfulton", "Bright Fulton <bright.fulton@gmail.com>"

  plugin.uses_repository :github => 'swipely/jenkins-git-notes-plugin'

  plugin.depends_on 'ruby-runtime', '0.10'
end
