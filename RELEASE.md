# Release and version

Steps when releasing:

* Run in terminal
    ```
    ESTIMATED_VERSION=1.0.4

    gh api repos/mundialis/github-workflows/releases/generate-notes -f tag_name="$ESTIMATED_VERSION" -f target_commitish=main -q .body
    ```
* Go to [new release](https://github.com/mundialis/github-workflows/releases/new)
* Copy the output of terminal command to the release description
* You can [compare manually](https://github.com/mundialis/github-workflows/compare/1.0.3...main) if all changes are included. If changes were pushed directly to main branch, they are not included.
* Check if `ESTIMATED_VERSION` increase still fits - we follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
* Fill in tag and release title with this version
* At the bottom of the release, add
  "generated with `gh api repos/mundialis/github-workflows/releases/generate-notes -f tag_name="$ESTIMATED_VERSION" -f target_commitish=main -q .body`" and replace `$ESTIMATED_VERSION` with the actual version.
* Make sure that the checkbox for "Set as the latest release" is checked so that this version appears on the main github repo page
* Now you can save the release