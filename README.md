# workflows

## (Python) Linting

The python3 linting workflow uses `black`, `flake8`, `pylint`, `ruff` and `super-linter` to check the
code quality.

You can use it e.g. like this:

```
name: Linting and code quality check

on:
  push:
    branches:
      - main
      - develop
  pull_request:

jobs:
  lint:
    uses: mundialis/github-workflows/.github/workflows/linting.yml@main
    with:
      pylint-version: '2.17.4'
      VALIDATE_JAVASCRIPT_STANDARD: false
      BASH_SEVERITY: 'warning'

```

or use e.g. `      pylint-version: ''` to skip checks with pylint. (If one of the versions is set to an empty string the code quality check will be
skipped.)

Examples how `flake8`, `pylint`, `markdownlint`, `shellcheck` and `ruff` can be configured are in the
[linting-config-examples](linting-config-examples)
folder. The `pylint` and `ruff` configuration files do not need to be created if they
are not to be customized, since they will be copied by the workflow if they
do not exists, although an additional `ruff.toml` file will be merged.
See [linting-config-examples](linting-config-examples/README.md) for more
details on how to configure the individual linters.

### (Python) Linting - reviewdog

For `ruff` and `black` linting, another workflow can propose suggestions to a pull request.
For this the additional file `post-pr-reviews.yml` has to be created e.g. like this:

```
name: Post PR code suggestions

on:
  workflow_run:
    workflows: ["Linting and code quality check"]
    types:
      - completed

jobs:
  post-pr-reviews:
    uses: mundialis/github-workflows/.github/workflows/post-pr-reviews.yml@main
```

It needs to be in the `main` branch to become active.
Code suggestions are only made for ruff and black if they are fixable by these tools.
Also suggestions can only be added near to lines changed in the PR.


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
    uses: mundialis/github-workflows/.github/workflows/grass-tests.yml@main
    # set NC_TEST_DATA to 'NC' for using NC GRASS GIS sample location
    # with:
    #   NC_TEST_DATA: 'NC'
```

## GRASS GIS addon manual

The GRASS GIS addon (and multi addon) manual workflow can be added to a repo
with a GRASS GIS addon inside to create the addon manual and pubish the manual
to GitHub Pages.

You can use it e.g. like this:

```
on:
  push:
    branches: [ main ]

jobs:
  grass-manual:
    uses: mundialis/github-workflows/.github/workflows/grass-manual.yml@main
```

Attention: you have to activate GitHub Pages for the repository (see
[here](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-from-a-branch))

After the GitHub Page is created you can go to the repo and click on the Settings next to "About" and check there "Use your GitHub Pages website". The GitHub Pages will appear under the description of the repo.

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

The python3 linting pre-commit hook uses `black`, `flake8`, `pylint`
and `ruff` to check the code quality.

You can use it by adding a `.pre-commit-config.yml` file to the repo containing e.g.:

```
repos:
-   repo: https://github.com/mundialis/github-workflows
    rev: 1.3.1
    hooks:
    -   id: linting
```

**Note**: Might need to adapt/update the release tag of repo within `pre-commit-config.yml`

An extended example can be found at [.pre-commit-example-config.yml](.pre-commit-example-config.yml)

It might take a while initially because the Dockerfile is build, after that cache is used.
To enable pre-commit, run

```
pip install pre-commit
pre-commit install
```

Then the code is linted before every commit.

To test the hooks without commits, you can run

```
pre-commit run -a
```

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

When the linting config files do not exist in your repository because no general adjustments
are necessary, the default configs are downloaded. To avoid duplicate downloads and to be
able to lint locally, they are kept and it makes sense to add them to the `.gitignore` file.
So if .pylintrc and .pylintrc_allowed_to_fail already exist, do nothing, else add them to
`.gitignore`. Also add some temporary config files for ruff to `.gitignore` like so:

```
.pylintrc
.pylintrc_allowed_to_fail
ruff-github-workflows.toml
ruff-merged.toml
```

Once in a while you can remove them manually to be in sync with the github-workflows default configs.

It is also recommended to add a `renovate.json` config with pre-commit enabled to your repository:

```
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "pre-commit": {
    "enabled": true
  }
}
```

### Development

To develop the pre-commit hook locally, cd into a code repository where you want to use it and run

```
pre-commit try-repo ../../github-workflows linting -a --verbose
```

If you want to start a container to debug the executed file, check last build docker image and run

```
docker run --rm -it --entrypoint sh -v $PWD:/src:rw,Z pre-commit-33a9cd78e77e8963da808aa71baf0b54
```

## Local linting


For quick local linting with the same flags as the linters use in the workflow and pre-commit,
you can add this snippet to your `~/.bashrc`:

Requirements:
- `pip install toml-union`
- have a local checkout of this repo at `~/repos/github-workflows` (or adjust below)

```
flake8() {
    if [ -z "$1" ]
    then
        LINT_TARGET=.
    else
        LINT_TARGET=$1
    fi

    /home/`whoami`/.local/bin/flake8 --count --statistics --show-source --jobs=4 $LINT_TARGET
}

alias black="black --check --diff --line-length 79 ."
alias pylint="pylint ."

ruff () {
    toml-union ruff.toml ~/repos/github-workflows/linting-config-examples/ruff.toml -o ruff-merged.toml
    /home/`whoami`/.local/bin/ruff check --config ruff-merged.toml --output-format=concise . --preview --unsafe-fixes
}

lint() {
    echo "Which Tool?"
    select tool in flake8 pylint black ruff
    do
        echo "Linting with $tool..."
        case $tool in
          flake8)
            flake8
            break
            ;;
          pylint)
            pylint
            break
            ;;
          black)
            black
            break
            ;;
          ruff)
            ruff
            break
            ;;
        esac
    done
}
```

Example usage:
```
17:49 $ lint
Which Tool?
1) flake8
2) pylint
3) black
4) ruff
#? 3
Linting with black...
All done! ✨ 🍰 ✨
208 files would be left unchanged.
```
