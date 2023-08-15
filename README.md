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
are not to be customized, scince they will be copied by the workflow if they
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


# pre-commit

## Python Linting

The python3 linting pre-commit hook uses `black`, `flake8` and `pylint` to check the
code quality.

You can use it by adding a `pre-commit-config.yml` file containing e.g.:
```
repos:
-   repo: https://github.com/mundialis/github-workflows
    rev: 8a5bab5f1b3e18d8edb8cb5d78a31e3b6b4646c5
    hooks:
    -   id: linting
```

It might take a while initially because the Dockerfile is build, after that cache is used.
To enable pre-commit, run
```
pip install pre-commit
pre-commit install
```
Then the code is linted before every commit.

As configuration is reused from github workflows, a linting workflow using above reusable
workflow must exist at `.github/workflows/linting.yml`. It is configurable:
- Linter versions:
  - Default versions specified in github-workflows/.github/workflows/linting.yml are used.
  - If overwritten in workflow which uses this workflow, only '' is supported for now
    to skip this linter.
  - Overwriting the version is not supported yet, the default version
    will still be used due to permission errors.
- Linter config files:
  - Files in code repository will be used.
  - If no config file in code repository exists, will be downloaded from github-workflows
    from main branch (same behaviour as in workflow)

In general what happens during pre-commit is that the Dockerfile of this repository is build
while having access to all files in this repository - if needed later, they need to be copied.
The linting.sh is then executed with the code repository mounted, so all files of that
repository are accessible only during runtime of the docker container.

### Development
To develop the pre-commit hook locally, cd into a code repository where you want to use it and run
```
pre-commit try-repo ../../github-workflows linting -a --verbose
```
If you want to start a container to debug the executed file, check last build docker image and run
```
docker run --rm -it --entrypoint sh -v $PWD:/src:rw,Z pre-commit-33a9cd78e77e8963da808aa71baf0b54
```
