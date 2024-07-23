FROM ghcr.io/super-linter/super-linter:latest

# pre-commit seems to set too strict permissions:
# error: could not lock config file //.gitconfig: Permission denied
# Therefore do not configure globally
# https://github.com/super-linter/super-linter/blob/main/lib/linter.sh#L345
RUN sed -i 's+git config --global --add safe.directory+git config --add safe.directory+g' /action/lib/linter.sh

# push to mundialis/super-linter
