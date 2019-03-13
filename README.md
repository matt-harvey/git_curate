# git curate

[![Gem Version][GV img]][Gem Version]

<img src="https://raw.githubusercontent.com/matt-harvey/git_curate/master/assets/demo2.gif" width="1000" alt="Demo" />

## Motivation

After a while, my local repo becomes cluttered with branches, and `git branch` outputs an awkwardly
long list. I want to delete some of those branches to bring that list back under control; but I
can't always remember which branches I want to keep from the branch names alone; and inspecting them
one at a time and _then_ running `git branch -D` in a separate step, is painful.

`git curate` is intended to ease this pain. It steps you through the local branches of a repo one at
a time, outputting the following information about each:

* Last commit date
* Last commit author
* Last commit subject
* Whether the branch has been merged into the current HEAD
* The status of the branch relative to the upstream branch it is tracking (if any)

You can then select whether to delete or keep each branch as you go.

**NOTE** `git curate` does _not_ run `git fetch` prior to generating its output. If you want to
be sure that the "Status vs upstream" column reflects the latest state of the upstream branches
as per their remote repository, you should run `git fetch` first.

## Installation

You'll need Ruby v2.1.10 or higher. Run

```
gem install git_curate
```

to install the executable.

## Usage

From within a git repo, run:

```
git curate
```

This will step you through your local branches one at a time, asking you whether to keep or
delete each branch in what should be a fairly self-explanatory fashion. Note the branch
you are currently on will not be included in the list, as `git` does not allow you to delete
the branch you're on.

(Note the space after `git`—we have effectively added a subcommand to `git` just by installing
a gem. When `git_curate` is installed, an executable is created called `git-curate`.
In general, for any executable of the form _git-xyz_ in your `PATH`, `git` will automatically
recognize _xyz_ as a subcommand, and will run that executable whenever that subcommand is invoked.)

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Run `rake -T` to see a list of Rake tasks available in the development environment.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/matt-harvey/git_curate).

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

[Gem Version]: https://rubygems.org/gems/git_curate
[GV img]: https://img.shields.io/gem/v/git_curate.svg?style=plastic
