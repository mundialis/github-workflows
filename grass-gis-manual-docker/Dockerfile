FROM osgeo/grass-gis:releasebranch_8_4-alpine

ARG ADDON_NAME
ARG GITHUB_REPOSITORY

WORKDIR /src
COPY . /src

RUN apk add gcc make python3-dev musl-dev linux-headers

# create environment to install requirements
RUN python -m venv addon-env
ENV PATH="/src/addon-env/bin:$PATH"
RUN test -e requirements.txt && pip3 install -r requirements.txt || echo "No requirements.txt"

# Compile GRASS GIS addon
RUN grass --tmp-location XY --exec g.extension extension=${ADDON_NAME} url=. prefix=build --verbose
RUN mv build/docs/html/${ADDON_NAME}.html build/docs/html/index.html

# Reset URL (for multi-addon in all html files)
RUN for HTML in $(ls -d /src/build/docs/html/*.html) ; do sed -i "s+file:///usr/local/grass84/docs/html/+https://grass.osgeo.org/grass-stable/manuals/+g" ${HTML} ; done
RUN for HTML in $(ls -d /src/build/docs/html/*.html) ; do sed -i "s+(<a href=\"\">history</a>)+(<a href=\"https://github.com/${GITHUB_REPOSITORY}/commits/main/\">history</a>)+g" ${HTML} ; done
RUN for HTML in $(ls -d /src/build/docs/html/*.html) ; do sed -i "s+<a href=\"\">+<a href=\"https://github.com/${GITHUB_REPOSITORY}\">+g" ${HTML} ; done

# Reset URLs for multi-addons in index html
RUN for DIR in $(ls -d /src/*/) ; do for HTML in $(ls -d /src/build/docs/html/*.html) ; do SUB_ADDON=$(basename $DIR) ; sed -i "s+https://grass.osgeo.org/grass-stable/manuals/${SUB_ADDON}.html\">+https://mundialis.github.io/${ADDON_NAME}/${SUB_ADDON}.html\">+g" ${HTML} ; done ; done
RUN for DIR in $(ls -d /src/*/) ; do for HTML in $(ls -d /src/build/docs/html/*.html) ; do SUB_ADDON=$(basename $DIR) ; sed -i "s+https://grass.osgeo.org/grass-stable/manuals/${SUB_ADDON}/${SUB_ADDON}.html\">+https://mundialis.github.io/${ADDON_NAME}/${SUB_ADDON}.html\">+g" ${HTML} ; done ; done
