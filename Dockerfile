FROM python:3-slim

ARG FLAKE8_VERSION
# RUN pip3 install flake8==${{ ${FLAKE8_VERSION} }}
RUN pip3 install flake8
RUN flake8 --version

COPY . /src/
RUN ls -lah /src/

RUN flake8 --config=/src/.flake8 --count --statistics --show-source .
