FROM python:3-slim

RUN apt-get update && apt-get install jq -y
RUN pip install --upgrade pip yq virtualenv

# Copy linting workflow to identify linter versions if needed
ENV WORKFLOW_LINTING_WORKFLOW=/github-workflows/.github/workflows/linting.yml
COPY .github/workflows/linting.yml $WORKFLOW_LINTING_WORKFLOW
# Install linters with default versions
RUN echo black==$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."black-version"'.default) >> /requirements.txt
RUN echo flake8==$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."flake8-version"'.default) >> /requirements.txt
RUN echo pylint==$(cat $WORKFLOW_LINTING_WORKFLOW | yq .on.workflow_call.inputs | jq -r '."pylint-version"'.default) >> /requirements.txt
RUN pip install -r requirements.txt

# Copy script to be executed on docker startup
# when code repository is mounted
COPY pre_commit_hooks/linting.sh /linting.sh

CMD [ "bash /linting.sh" ]
