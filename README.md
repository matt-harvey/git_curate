# git curate

[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]
[![Coverage Status][CS img]][Coverage Status]
[![Awesome][AR img]][Awesome Ruby]

<img src="https://raw.githubusercontent.com/matt-harvey/git_curate/master/assets/demo.gif" width="1000" alt="Demo" />

## Motivation

After a while, my local repo becomes cluttered with branches, and `git branch` outputs an awkwardly
long list. I want to delete some of those branches to bring that list back under control; but I
can&#8217;t always remember which branches I want to keep from the branch names alone; and inspecting them
one at a time and _then_ running `git branch -D` in a separate step, is painful.

`git curate` is intended to ease this pain. It steps you through the local branches of a repo one at
a time, outputting the following information about each:

* Last commit date
* Last commit hash
* Last commit author
* Last commit subject
* Whether the branch has been merged into the current HEAD
* The status of the branch relative to the upstream branch it is tracking (if any)

You can then select whether to delete or keep each branch as you go.

**NOTE** `git curate` does _not_ run `git fetch` prior to generating its output. If you want to
be sure that the &ldquo;Status vs upstream&rdquo; column reflects the latest state of the upstream branches
as per their remote repository, you should run `git fetch` first.

## Installation

You&#8217;ll need Ruby (v2.4.9 or greater) installed. Run:

```
gem install git_curate
```

to install the executable.

## Usage

From within a git repo, run:

```
git curate
```

This will step you through your local branches one at a time, outputting some information about
each, and asking you whether to keep or delete each branch.

At each branch, enter &ldquo;k&rdquo;&mdash;or simply press Enter&mdash;to _keep_ the branch and move to the next one;
or enter &ldquo;d&rdquo; to select the branch for deletion.

Entering &ldquo;e&rdquo; will end the session immediately, deleting all selected branches; and &ldquo;a&rdquo; will
abort the session without deleting any branches. Once the final branch has been considered,
any selected branches will be immediately deleted.

Note the branch you are currently on will not be included in the list, as `git` does not allow you to delete
the branch you&#8217;re on. (The same applies to any branches that are currently checked out in other
[worktrees](https://git-scm.com/docs/git-worktree).)

If you just want to view the information about your local branches without stepping through
them interactively, enter `git curate --list` or `git curate -l`. Your current branch _will_
be included in this list in this case.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/matt-harvey/git_curate).

To start working on `git_curate`, `git clone` and `cd` into your fork of the repo, then run `bin/setup` to
install dependencies.

To run the test suite, run `bundle exec rake spec`. For a list of other Rake tasks, run `bundle exec rake -T`.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

[Gem Version]: https://rubygems.org/gems/git_curate
[Build Status]: https://travis-ci.org/matt-harvey/git_curate
[Coverage Status]: https://coveralls.io/github/matt-harvey/git_curate
[Awesome Ruby]: https://awesome-ruby.com/#-git-tools

[GV img]: https://img.shields.io/gem/v/git_curate.svg
[BS img]: https://img.shields.io/travis/matt-harvey/git_curate.svg
[CS img]: https://img.shields.io/coveralls/matt-harvey/git_curate.svg
[AR img]: https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg
