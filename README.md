# git curate

## Motivation

After a while, my local repo becomes cluttered with branches, and `git branch` outputs an awkwardly
long list. I want to delete some of those branches to bring that list back under control; but I
can't always remember which branches I want to keep from the branch names alone; and inspecting them
one at a time and _then_ running `git branch -D` in a separate step, is painful.

`git curate` is intended to ease this pain. It steps you through the local branches of a repo one at a
time, outputting a small amount of information about each branch (last commit date, author and
summary), and prompting you either to keep or to delete each branch as you go.

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
you are currently on will not be included in the list.

## Development

After checking out the repo, run `bin/setup` to install dependencies.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/matt-harvey/git_curate.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
