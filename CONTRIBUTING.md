## Contributing To lograge

We want to start off by saying thank you
for using and contributing to lograge.  This project is a labor of
love, and we appreciate all of the users that catch bugs, make
performance improvements, and help with documentation. Every
contribution is meaningful, so thank you for participating. That being
said, here are a few guidelines that we ask you to follow so we can
successfully address your issue.


### Submitting Issues

Please include the following:

* Lograge version/tag/commit hash you are using
* The Rails version
* Which RVM/rbenv/chruby/etc version you are using if so
* The Ruby version your are using
* The Operating System
* A stacktrace or log output if available

Describe your issue and give as much steps as necessary to reproduce
it.  If possible add what you expected to happen and what actually
happened to get a better understanding of the problem.

### Submitting A Pull Request

If you want to submit a pull request make sure your code is cleaned up
and no artifacts are left behind.  Make sure your commits are clearly
structured and follow _the seven rules of a great commit message_:

* Separate subject from body with a blank line
* Limit the subject line to 50 characters
* Capitalize the subject line
* Do not end the subject line with a period
* Use the imperative mood in the subject line
* Wrap the body at 72 characters
* Use the body to explain what and why vs. how

(Taken from [How to Write a Git Commit Message](http://chris.beams.io/posts/git-commit/))

Make sure `rake ci` passes and that you have *added* tests for your
change.

*Thank you.*

This document is inspired by the [Rubinius](https://raw.githubusercontent.com/rubinius/rubinius/master/CONTRIBUTING.md) project.
