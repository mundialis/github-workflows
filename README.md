# workflows

## Python Linting
The python3 linting workflow uses `black`, `flake8` and `pylint` to check the
code quality.

You can use it e.g. like this:
```
name: Python Flake8, black and pylint code quality check

on: [push]

jobs:
  lint:
    uses: mundialis/github-workflows/.github/workflows/linting.yml@main
    with:
      pylint-version: '2.17.4'
```
Examples how `flake8` and `pylint` can be configured are in the
[linting-config-examples](https://github.com/mundialis/github-workflows/blob/main/linting-config-examples)
folder. The `pylint` configuration files do not need to be created if they
are not to be customized, scince they will be copied by the workflow if thes
do not exists.

If one of the versions is set to an empty string the code quality check will be
skipped.
