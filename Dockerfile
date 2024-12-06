FROM ghcr.io/super-linter/super-linter:latest

# This Dockerfile is used by the linting pre-commit hook.
# Unfortunately there is no config option yet to specify the name or path
# of this image, so it must be on root level simply named Dockerfile...

RUN apk add jq wget
RUN pip install --upgrade pip yq virtualenv toml-union

# Copy linting workflow to identify linter versions if needed
ENV WORKFLOW_LINTING_WORKFLOW=/github-workflows/.github/workflows/linting.yml
COPY .github/workflows/linting.yml $WORKFLOW_LINTING_WORKFLOW
# Install linters with default versions
RUN echo black==$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."black-version"'.default) >> /requirements.txt
RUN echo flake8==$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."flake8-version"'.default) >> /requirements.txt
RUN echo pylint==$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."pylint-version"'.default) >> /requirements.txt
RUN echo ruff==$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."ruff-version"'.default) >> /requirements.txt
RUN pip install -r requirements.txt

# Copy script to be executed on docker startup
# when code repository is mounted
COPY pre_commit_hooks/linting.sh /linting.sh

CMD [ "bash /linting.sh" ]


# pre-commit seems to set too strict permissions:
# error: could not lock config file //.gitconfig: Permission denied
# Therefore do not configure globally
# https://github.com/super-linter/super-linter/blob/main/lib/linter.sh#L345
RUN sed -i 's+git config --global --add safe.directory+git config --add safe.directory+g' /action/lib/linter.sh

# save to be able to export later
RUN echo "export RUN_LOCAL=TRUE" >> /super-linter.txt
RUN echo "export DEFAULT_BRANCH=main" >> /super-linter.txt
RUN echo "export DEFAULT_WORKSPACE=/src" >> /super-linter.txt
RUN echo BASH_SEVERITY=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."BASH_SEVERITY"'.default) >> /super-linter.txt
RUN echo VALIDATE_BASH=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_BASH"'.default) >> /super-linter.txt
RUN echo VALIDATE_BASH_EXEC=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_BASH_EXEC"'.default) >> /super-linter.txt
RUN echo VALIDATE_CSS=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_CSS"'.default) >> /super-linter.txt
RUN echo VALIDATE_DOCKERFILE_HADOLINT=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_DOCKERFILE_HADOLINT"'.default) >> /super-linter.txt
RUN echo VALIDATE_GITHUB_ACTIONS=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_GITHUB_ACTIONS"'.default) >> /super-linter.txt
RUN echo VALIDATE_HTML=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_HTML"'.default) >> /super-linter.txt
RUN echo VALIDATE_JAVASCRIPT_ES=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_JAVASCRIPT_ES"'.default) >> /super-linter.txt
RUN echo VALIDATE_JAVASCRIPT_STANDARD=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_JAVASCRIPT_STANDARD"'.default) >> /super-linter.txt
RUN echo VALIDATE_JSON=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_JSON"'.default) >> /super-linter.txt
RUN echo VALIDATE_MARKDOWN=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_MARKDOWN"'.default) >> /super-linter.txt
RUN echo VALIDATE_POWERSHELL=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_POWERSHELL"'.default) >> /super-linter.txt
RUN echo VALIDATE_RENOVATE=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_RENOVATE"'.default) >> /super-linter.txt
RUN echo VALIDATE_XML=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_XML"'.default) >> /super-linter.txt
RUN echo VALIDATE_YAML=$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."VALIDATE_YAML"'.default) >> /super-linter.txt
