#!/usr/bin/env bash

# Supposed to run within Docker container as part of pre-commit hook
# Assumptions:
# - workflow in code repo named linting.yml
# - workflow in code repo makes use of reusable workflow

# pre-commit will automatically mount the repository source
# as a volume using -v $PWD:/src:rw,Z
CODE_REPO_PATH=/src
CODE_LINTING_WORKFLOW=${CODE_REPO_PATH}/.github/workflows/linting.yml

# Exit when code repository has no linting workflow set
if test -f "$CODE_LINTING_WORKFLOW"
then
    echo "$CODE_LINTING_WORKFLOW exists."
else
    echo "no lint workflow found at $CODE_LINTING_WORKFLOW, skip check."
    exit 0
fi

####################################
# Overwrite linter versions if set #
####################################

cat $CODE_LINTING_WORKFLOW | grep black-version
if [ $? -ne 0 ]
then
    echo "black version not overwritten in code workflow"
else
    echo "TODO: parse yml file and overwrite requirements.txt"
fi

cat $CODE_LINTING_WORKFLOW | grep flake8-version
if [ $? -ne 0 ]
then
    echo "flake8 version not overwritten in code workflow"
else
    echo "TODO: parse yml file and overwrite requirements.txt"
fi

if [ $(yq '.jobs.lint.with | has("pylint-version")' $CODE_LINTING_WORKFLOW) == true ]
then
    echo "TODO: parse yml file and overwrite requirements.txt"
    DEFAULT_PYLINT_VERSION=$(cat /requirements.txt | grep pylint== | cut -d "=" -f 3)
    NEW_PYLINT_VERSION=$(yq '.jobs.lint.with."pylint-version"' $CODE_LINTING_WORKFLOW)
    # TODO: if NEW_PYLINT_VERSION == "", do not run pylint
else
    echo "pylint version not overwritten in code workflow"
fi

###################
# Install linters #
###################
# TODO: if versions are not default versions, this fails due to missing permissions
pip3 install -r /requirements.txt
flake8 --version
pylint --version
black --version

########
# lint #
########

cd /src

# TODO: check from above if version is set to "", then skip

echo
echo "FLAKE8:"
flake8 --config=/src/.flake8 --count --statistics --show-source .
echo

echo "PYLINT:"
if test -f "/src/.pylintrc"
then
    echo ".pylintrc exists"
else
    echo ".pylintrc does not exists. Will be downloaded."
    wget https://raw.githubusercontent.com/mundialis/github-workflows/main/linting-config-examples/.pylintrc
fi
pylint .
echo

echo "PYLINT more strict:"
if test -f "/src/.pylintrc_allowed_to_fail"
then
    echo ".pylintrc_allowed_to_fail exists"
else
    echo ".pylintrc_allowed_to_fail does not exists. Will be downloaded."
    wget https://raw.githubusercontent.com/mundialis/github-workflows/main/linting-config-examples/.pylintrc_allowed_to_fail
fi
pylint --rc-file=.pylintrc_allowed_to_fail .
echo

echo "BLACK:"
black --check --diff --line-length 79 .
