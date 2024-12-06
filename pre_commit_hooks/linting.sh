#!/usr/bin/env bash

# Supposed to run within Docker container as part of pre-commit hook
# Assumptions:
# - workflow in code repo named linting.yml
# - workflow in code repo makes use of reusable workflow

# pre-commit will automatically mount the repository source
# as a volume using -v $PWD:/src:rw,Z
CODE_REPO_PATH=/src
CODE_LINTING_WORKFLOW=${CODE_REPO_PATH}/.github/workflows/linting.yml

echo "##########################################"

# Exit when code repository has no linting workflow set
if test -f "$CODE_LINTING_WORKFLOW"
then
    echo "$CODE_LINTING_WORKFLOW exists - continue."
else
    echo "no lint workflow found at $CODE_LINTING_WORKFLOW, skip check."
    exit 0
fi

RUN_BLACK=TRUE
RUN_FLAKE8=TRUE
RUN_PYLINT=TRUE
RUN_RUFF=TRUE
RUN_SUPERLINTER=TRUE

####################################
# Overwrite linter versions if set #
####################################

if [ $(yq '.jobs.lint.with | has("black-version")' $CODE_LINTING_WORKFLOW) == true ]
then
    DEFAULT_BLACK_VERSION=$(cat /requirements.txt | grep black== | cut -d "=" -f 3)
    NEW_BLACK_VERSION=$(yq '.jobs.lint.with."black-version"' $CODE_LINTING_WORKFLOW)
    if [ "$(echo $NEW_BLACK_VERSION | tr '"' 'x')" = "xx" ]
    then
        RUN_BLACK=FALSE
        echo "- black configured to be skipped (empty string)"
    elif [ $DEFAULT_BLACK_VERSION != $NEW_BLACK_VERSION ]
    then
        # sed would fail with Permission denied
        # sed -i "s+$DEFAULT_BLACK_VERSION+$NEW_BLACK_VERSION+g" /requirements.txt
        echo "- Warning: overwritten black version will not be installed!"
    fi
else
    echo "- black version not overwritten in code workflow"
fi

if [ $(yq '.jobs.lint.with | has("flake8-version")' $CODE_LINTING_WORKFLOW) == true ]
then
    DEFAULT_FLAKE8_VERSION=$(cat /requirements.txt | grep flake8== | cut -d "=" -f 3)
    NEW_FLAKE8_VERSION=$(yq '.jobs.lint.with."flake8-version"' $CODE_LINTING_WORKFLOW)
    if [ "$(echo $NEW_FLAKE8_VERSION | tr '"' 'x')" = "xx" ]
    then
        RUN_FLAKE8=FALSE
        echo "- flake8 configured to be skipped (empty string)"
    elif [ $DEFAULT_FLAKE8_VERSION != $NEW_FLAKE8_VERSION ]
    then
        # sed would fail with Permission denied
        # sed -i "s+$DEFAULT_FLAKE8_VERSION+$NEW_FLAKE8_VERSION+g" /requirements.txt
        echo "- Warning: overwritten flake8 version will not be installed!"
    fi
else
    echo "- flake8 version not overwritten in code workflow"
fi

if [ $(yq '.jobs.lint.with | has("pylint-version")' $CODE_LINTING_WORKFLOW) == true ]
then
    DEFAULT_PYLINT_VERSION=$(cat /requirements.txt | grep pylint== | cut -d "=" -f 3)
    NEW_PYLINT_VERSION=$(yq '.jobs.lint.with."pylint-version"' $CODE_LINTING_WORKFLOW)
    if [ "$(echo $NEW_PYLINT_VERSION | tr '"' 'x')" = "xx" ]
    then
        RUN_PYLINT=FALSE
        echo "- pylint configured to be skipped (empty string)"
    elif [ $DEFAULT_PYLINT_VERSION != $NEW_PYLINT_VERSION ]
    then
        # sed would fail with Permission denied
        # sed -i "s+$DEFAULT_PYLINT_VERSION+$NEW_PYLINT_VERSION+g" /requirements.txt
        echo "- Warning: overwritten pylint version will not be installed!"
    fi
else
    echo "- pylint version not overwritten in code workflow"
fi

if [ $(yq '.jobs.lint.with | has("ruff-version")' $CODE_LINTING_WORKFLOW) == true ]
then
    DEFAULT_RUFF_VERSION=$(cat /requirements.txt | grep ruff== | cut -d "=" -f 3)
    NEW_RUFF_VERSION=$(yq '.jobs.lint.with."ruff-version"' $CODE_LINTING_WORKFLOW)
    if [ "$(echo $NEW_RUFF_VERSION | tr '"' 'x')" = "xx" ]
    then
        RUN_RUFF=FALSE
        echo "- ruff configured to be skipped (empty string)"
    elif [ $DEFAULT_RUFF_VERSION != $NEW_RUFF_VERSION ]
    then
        # sed would fail with Permission denied
        # sed -i "s+$DEFAULT_RUFF_VERSION+$NEW_RUFF_VERSION+g" /requirements.txt
        echo "- Warning: overwritten ruff version will not be installed!"
    fi
else
    echo "- ruff version not overwritten in code workflow"
fi

echo

###################
# Install linters #
###################
# TODO: if versions are not default versions, this fails due to missing permissions
pip3 install -r /requirements.txt
echo
echo "flake8: `flake8 --version`"
echo "pylint: `pylint --version`"
echo "black: `black --version`"
echo "ruff: `ruff --version`"

########
# lint #
########

cd $CODE_REPO_PATH

FAILINGSTEP=""
RETURNCODE=0
if [ $RUN_FLAKE8 != "FALSE" ]
then
    echo
    echo "FLAKE8:"
    flake8 --config=.flake8 --count --statistics --show-source .
    if [ $? -ne 0 ]
    then
        RETURNCODE=1
        FAILINGSTEP="FLAKE8"
    fi
else
    echo
    echo "FLAKE8 configured to be skipped"
fi

if [ $RUN_PYLINT != "FALSE" ]
then
    echo
    echo "PYLINT:"
    if test -f ".pylintrc"
    then
        echo ".pylintrc exists"
    else
        # Same behaviour as in workflow
        echo ".pylintrc does not exists. Will be downloaded."
        wget https://raw.githubusercontent.com/mundialis/github-workflows/main/linting-config-examples/.pylintrc
    fi
    pylint .
    if [ $? -ne 0 ]
    then
        RETURNCODE=1
        FAILINGSTEP="$FAILINGSTEP PYLINT (run 'pylint .')"
    fi

    echo
    echo "PYLINT more strict:"
    if test -f ".pylintrc_allowed_to_fail"
    then
        echo ".pylintrc_allowed_to_fail exists"
    else
        # Same behaviour as in workflow
        echo ".pylintrc_allowed_to_fail does not exists. Will be downloaded."
        wget https://raw.githubusercontent.com/mundialis/github-workflows/main/linting-config-examples/.pylintrc_allowed_to_fail
    fi
    pylint --rc-file=.pylintrc_allowed_to_fail .
else
    echo
    echo "PYLINT configured to be skipped (run 'pylint --rc-file=.pylintrc_allowed_to_fail .')"
fi

if [ $RUN_BLACK != "FALSE" ]
then
    echo
    echo "BLACK:"
    black --check --diff --line-length 79 .
    if [ $? -ne 0 ]
    then
        RETURNCODE=1
        FAILINGSTEP="$FAILINGSTEP BLACK (run 'black --check --diff --line-length 79 .')"
    fi
else
    echo
    echo "BLACK configured to be skipped"
fi

if [ $RUN_RUFF != "FALSE" ]
then
    echo
    echo "RUFF:"
    wget -q https://raw.githubusercontent.com/mundialis/github-workflows/main/linting-config-examples/ruff.toml -O ruff-github-workflows.toml
    # Merge shared config with local one. Also works if no ruff.toml exists.
    # The `| awk NF` at the end omits output of empy lines.
    toml-union ruff.toml ruff-github-workflows.toml -o ruff-merged.toml | awk NF
    # Run ruff (apply fixes for suggestions)
    # ruff check --config ruff-merged.toml . --preview --fix --unsafe-fixes
    # Run ruff (output annotations on fixable errors)
    # stdout is omitted, despite of `1>&2` ?
    ruff check --config ruff-merged.toml --output-format=github . --preview --unsafe-fixes 1>&2
    if [ $? -ne 0 ]
    then
        RETURNCODE=1
        FAILINGSTEP="$FAILINGSTEP RUFF (run 'ruff check --config ruff-merged.toml --output-format=github . --preview --unsafe-fixes')"
    else
        # See above - STDOUT is omitted, so print here default output
        echo "All checks passed!"
    fi
else
    echo
    echo "RUFF configured to be skipped"
fi

if [ $RUN_SUPERLINTER != "FALSE" ]
then
    echo
    echo "SUPERLINTER:"
    # overwrite rules with default config
    . /super-linter.txt && export $(cut -d= -f1 /super-linter.txt)
    # overwrite rules with custom repo config
    `cat /src/.github/workflows/linting.yml | yq .jobs.lint.with | grep -v "-version" | jq -r 'to_entries[] | "export \(.key)=\(.value)"'`
    # run linting script
    bash /action/lib/linter.sh
    if [ $? -ne 0 ]
    then
        RETURNCODE=1
        FAILINGSTEP="$FAILINGSTEP SUPERLINTER (run '/action/lib/linter.sh')"
    fi
else
    echo
    echo "SUPERLINTER configured to be skipped"
fi


if [ $RETURNCODE -ne 0 ]
then
    echo "Failing steps: ${FAILINGSTEP}"
fi
exit $RETURNCODE
