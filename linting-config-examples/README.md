# Hints to add linting workflow

The reusable linting workflow tries to be as strict as possible.
It is up to the repositories using it to define reasonable exceptions.
Here are some ways described how this can be done.

## flake8
Simply add a .flake8 config file to the root of your repository
See example here or visit [official documentation](https://flake8.pycqa.org/en/latest/user/configuration.html).
`flake8 --config=.flake8 --count --statistics --show-source .`

## black
Nothing needed, it uses config file of flake8.
See https://black.readthedocs.io/en/stable/guides/using_black_with_other_tools.html
`black --check --diff --line-length 79 .`

## pylint
There are two different configs - one which must be followed and one which is more strict
but allowed to fail. Both are contained in this repository and used for the reusable linting
workflow. If that fits, all is good. If you need more specific adjustments, name them the
same way and place them in your directory root to adjust.
`pylint .`
`pylint --rc-file=.pylintrc_allowed_to_fail .`

## ruff
ruff contains rules inspired by black, flake8, pylint and more and is extremely fast in linting and formatting Python code.
The linting config is aligned to the [one from GRASS GIS](https://github.com/OSGeo/grass/blob/main/pyproject.toml).
Per default, a lot of linting rules are active. If needed, add a `ruff.toml` config file to the root of your repository
and add rules which to ignore.
See example here or visit [official documentation](https://docs.astral.sh/ruff/).
```
ruff check --config ruff-merged.toml --output-format=full . --preview --unsafe-fixes
```
Merge repository-specific `ruff.toml` and the one from this repo:
```
pip install toml-union
wget --continue https://raw.githubusercontent.com/mundialis/github-workflows/refs/heads/main/linting-config-examples/ruff.toml -O /tmp/ruff.toml -q
toml-union ruff.toml /tmp/ruff.toml -o ruff-merged.toml
```
For initial setup in your repository, the list of rules to be ignored can be generated:
```
ruff check --config ruff-merged.toml . --preview --unsafe-fixes --output-format json | jq .[].code | sort -u
```
(Need to add `,` at the end of each line).

## superlinter
Superlinter is a wrapper for many different linters. Each has a different way to be configured.
Example config files exist for [markdownlint](https://github.com/DavidAnson/markdownlint)
and [shellcheck](https://github.com/koalaman/shellcheck).

Some allow exceptions to be defined directly on top of a file or above the line.

### markdownlint
- See example config file `.markdownlint.yaml`
- Disable checks inside .md files on top of file:
```
<!-- markdownlint-configure-file {"MD013": { "line_length": 150 }} -->
```
Or more sophisticated
```
<!-- markdownlint-configure-file
{
  "MD013": { "line_length": 150 },
  "MD024": { "siblings_only": true },  # no-duplicate-heading, in CHANGELOG it is ok
  "MD034": false # no-bare-urls
}
-->
```

### shellcheck
- See example config file `.shellcheckrc`
- Disable checks inside .sh files, direclty above line:
```
# shellcheck disable=SC2317
```

### hadolint
[Hadolint](https://github.com/hadolint/hadolint) lints Dockerfiles.
- Disable checks inside Dockerfiles, directly above line:
```
# hadolint ignore=DL3018
```

## Run locally

When not using pre-commit, all files can be checked locally via docker command.
This way, all used linters don't need to be installed locally individually.
As linters might change, check in `.github/workflows/linting.yml` around L160
which environmental variables can to be used.

```
docker run \
  -e LOG_LEVEL=DEBUG \
  -e RUN_LOCAL=true \
  -e DEFAULT_BRANCH=main \
  -e BASH_SEVERITY=warning \
  -e VALIDATE_BASH=true \
  -e VALIDATE_BASH_EXEC=true \
  -e VALIDATE_CSS=true \
  -e VALIDATE_DOCKERFILE_HADOLINT=true \
  -e VALIDATE_GITHUB_ACTIONS=true \
  -e VALIDATE_HTML=true \
  -e VALIDATE_JAVASCRIPT_ES=true \
  -e VALIDATE_JAVASCRIPT_STANDARD=true \
  -e VALIDATE_JSON=true \
  -e VALIDATE_MARKDOWN=true \
  -e VALIDATE_POWERSHELL=true \
  -e VALIDATE_RENOVATE=true \
  -e VALIDATE_XML=true \
  -e VALIDATE_YAML=true \
  -v /home/ctawalika/repos/actinia/actinia-core/:/tmp/lint \
  ghcr.io/super-linter/super-linter:latest
```

Or with only one certain linter:

```
docker run \
  -e RUN_LOCAL=true \
  -e DEFAULT_BRANCH=main \
  -e VALIDATE_BASH=true \
  -v ${HOME}/repos/actinia/actinia-core/:/tmp/lint \
  ghcr.io/super-linter/super-linter:latest
```
