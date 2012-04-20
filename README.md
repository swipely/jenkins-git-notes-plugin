# Add [git-notes](http://man.github.com/git/git-notes.html) with [Jenkins](http://jenkins-ci.org/) build status!

This is a [pure Ruby Jenkins plugin](https://github.com/jenkinsci/jenkins.rb) which annotates git commits with Jenkins
build information using the awesome git-notes functionality.


## Background

Haven't heard of git-notes?  You're not alone.  Although first [proposed]
(http://thread.gmane.org/gmane.comp.version-control.git/52598/) in 2007 and released in [1.6.6]
(https://github.com/gitster/git/blob/master/Documentation/RelNotes/1.6.6.txt), many still haven't heard of the feature.
In short, git-notes allows namespaced data to be natively associated with a commit after-the-fact.

So git-notes seemed like it might a good place to store meta-information like build status, both for human and
programmatic consumption, but then [GitHub made it irresistible](https://github.com/blog/707-git-notes-display) by
displaying the notes prominently on commit pages.  Ever wanted to see the build status of the last commit in a pull
request?

And since [Jenkins made it simple](http://jenkins-ci.org/content/beginning-new-era-ruby-plugins-now-reality) to try out
new ideas like this, it was an easy decision to start work on this plugin!


## Install

1. [Get](https://jenkins-ci.org/) Jenkins.

2. Install the [ruby-runtime](http://jenkins-ci.org/plugin/ruby-runtime/) plugin and the [git-notes]
(https://wiki.jenkins-ci.org/display/JENKINS/git-notes+Plugin) plugin.

3. Restart Jenkins.

![install the ruby-runtime and git-notes plugins]
(https://github.com/swipely/jenkins-git-notes-plugin/raw/master/.README/plugin-manager.png)


## Use

With the git-notes plugin installed in Jenkins, you simply check the "Publish build result as git-notes" box in the
publish section of the build config:

![check the publish git-notes box]
(https://github.com/swipely/jenkins-git-notes-plugin/raw/master/.README/publish-box.png)

Your commits will then get the latest build status, which GitHub will display in a pretty yellow box at the bottom of
the commit page and under the "jenkins" namespace:

![profit!](https://github.com/swipely/jenkins-git-notes-plugin/raw/master/.README/github-view.png)

As you can see, the format of the notes is JSON.  Here is an example which has been marked up with comments for clarity:

    {
      "built_on": "master",                 /* name of node that build ran on */
      "duration": 1.786,                    /* number of seconds that the build took */
      "full_display_name": "junk #45",      /* name of the build, project + number */
      "id": "2012-03-29_09-46-01",          /* unique ID for the build */
      "number": 45,                         /* project build sequence number */
      "result": "SUCCESS",                  /* result string: ABORTED|FAILURE|NOT_BUILT|SUCCESS|UNSTABLE */
      "status_message": "stable",           /* recent project status */
      "time": "2012-03-29 09:46:01 -0400",  /* time that build was scheduled */
      "url": "job/junk/45/"                 /* build URL, relative to root */
    }


## Develop

Interested in contributing to the Jenkins git-notes plugin?  Great!  Start [here]
(https://github.com/jenkinsci/jenkins.rb/wiki/Getting-Started-With-Ruby-Plugins).

Start the development server and set up a build config to test with:

    bundle install
    bundle exec jpi server
    open http://localhost:8080

Run the tests:

    bundle exec rspec
