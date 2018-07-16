# git curate

## Motivation

After a while, my local repo becomes full of branches, and `git branch` outputs an awkwardly long
list. I want to delete some of those branches to bring that list back under control; but I
can't always remember which branches are which from the name alone, and inspecting them one at a
time and _then_ running `git branch -D` in a separate step, is painful.

I wrote `git curate` to ease this pain. It steps through the local branches of a repo one at a
time, outputting a small amount of information about each branch (author, last commit date and
last commit summary), and prompting you to either keep or delete each branch as you go.

## Installation

```
gem install git_curate
```

## Usage

From within a git repo, run:

```
git curate
```

This will step you through your local branches one at a time, prompting you whether to keep or
delete each branch in what should be a self-explanatory fashion.

## Development

After checking out the repo, run `bin/setup` to install dependencies.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/matt-harvey/tabulo.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
