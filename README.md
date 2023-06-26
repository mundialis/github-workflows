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
    uses: mundialis/workflows/.github/github-workflows/linting.yml@main
    with:
      pylint-version: '2.17.4'
```
Examples how `flake8` and `pylint` can be configured are in the [linting-config-examples](https://github.com/mundialis/github-workflows/blob/main/linting-config-examples) folder.
