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


## GRASS GIS addon tests

The GRASS GIS addon tests can be added to a repo with one GRASS GIS test.

The workflow downloads the NC sample location if the workflow is configured using `with`
`NC_TEST_DATA: 'NC'`.


You can use it e.g. like this:
```
name: Run tests for GRASS GIS addons
on:
  push:
    branches: [ main ]
  pull_request:
    # The branches below must be a subset of the branches above
    branches: [ main ]

jobs:
  tests:
    uses: mundialis/github-workflows/.github/workflows/grass-tests.yml@grass-tests
    # set NC_TEST_DATA to 'NC' for using NC GRASS GIS sample location
    # with:
    #   NC_TEST_DATA: 'NC'
```


## Python Publishing

The python publish workflow creates a wheel and uploads it to release assets.
Also the python package is published on PyPI or test PyPI.

To use this workflow in the repo the **secrets** `TEST_PYPI_API_TOKEN` or
`PYPI_API_TOKEN` have to be set. Additional, you have to check under `Settings > Actions > General > Workflow permissions` the `Read and write permissions`.

For publishing on test PyPI use e.g.:
```
name: Upload Python Package to test PyPI

on:
  release:
    types: [published]

jobs:
  publish-python:
    uses: mundialis/github-workflows/.github/workflows/python-publish.yml@main
    with:
      test_pypi: true
    secrets:
      PYPI_PASSWORD: ${{ secrets.TEST_PYPI_API_TOKEN }}
```

For publishing on PyPI use e.g.:
```
name: Upload Python Package to PyPI

on:
  release:
    types: [published]

jobs:
  publish-python:
    uses: mundialis/github-workflows/.github/workflows/python-publish.yml@main
    secrets:
      PYPI_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
```
