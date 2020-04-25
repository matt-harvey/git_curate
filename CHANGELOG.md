# Changelog

### v1.0.0

* Remove support for Ruby < v2.4.9.

### v0.8.0

* Change options to make them more memorable/obvious
* Always print options legend at top, if in interactive mode
* Add a column showing last commit hash
* Tweak column header layout
* Fix warnings on Ruby 2.7
* Fix minor error in README

### v0.7.5

* Drop support for Ruby 2.1
* Dependency version upgrades

### v0.7.4

* Dependency version upgrades

### v0.7.3

* Remove blank vertical gutters either side of output table
* Dependency versions updated

### v0.7.2

* Nicer error messages; for example, if `git curate` is run outside of a git repo, the user will now see
  the same error message as they would see from running `git branch` (as opposed to seeing an unsightly stack trace)
* Performance improvements: it now runs faster, as the number of system calls made by the
  application is reduced
* Improvements to code structure and internal documentation

### v0.7.1

* Fix errors on -h, -v and --version options due to incorrect exit code handling
* Fix error when branch name is the same as the name of a filepath
* Get test coverage to 100%

### v0.7.0

* Show "no" option as capital "N", to hint that it's the default
* Get user input case-insensitively
* More unit tests
* Build status and coverage badges added to README

### v0.6.4

* Fix breakage on Ruby <= 2.3 due to unsupported Regex #match? method.

### v0.6.3

* Fix formatting of output on Windows.

### v0.6.2

* Upgrade dependency versions.

### v0.6.1

* Align columns correctly when multibyte Unicode characters appear in commit messages.

### v0.6.0

* Simply hitting Enter now lets you skip a branch without marking it for deletion;
  no need to type "n".

### v0.5.1

* Fix upstream branch not showing for current branch in `git curate -l`

### v0.5.0

* Add `-l` option to output branch information non-interactively
* Add help output (`-h` option)

### v0.4.3

* Upgrade dependency versions

### v0.4.2

* Cap output to terminal width automatically.
* Documentation improvements.

### v0.4.0

* Add "Status vs upstream" column.

### v0.3.0

* Add "Merged into HEAD?" column.

### v0.2.0

* Make output more compact.
* Improve README.

### v0.1.1

Fix runtime dependency specification.

### v0.1.0

Initial release.
