FROM osgeo/grass-gis:main-alpine

ARG NC_TEST_DATA=""

WORKDIR /src
COPY . /src
COPY test-docker/test.sh /src

RUN test -e test-docker/ && rm -rf test-docker/

# Pin Python to 3.12 (from Alpine 3.20 compat repo) to avoid the
# multiprocessing forkserver regression in Python 3.14 which breaks
# GRASS's temporal RPC server (grass/pygrass/rpc/base.py thread_checker).
# The forkserver address file is no longer found on Process.start()
# in Python 3.14, causing FileNotFoundError during server restart.
# See: https://github.com/mundialis/v.alkis.buildings.import/pull/30
RUN apk add --no-cache python3.12 py3.12-pip python3.12-dev gcc make musl-dev linux-headers
RUN python3.12 -m venv addon-env
ENV PATH="/src/addon-env/bin:$PATH"
RUN test -e requirements.txt && pip3 install -r requirements.txt || echo "No requirements.txt"

# run tests if NC_TEST_DATA is set to NC with downloaded NC test loaction otherwise in empty location
RUN grass -c epsg:3358 /grassdb/nc_spm_empty --exec bash test.sh ${NC_TEST_DATA}
