FROM osgeo/grass-gis:main-alpine

ARG NC_TEST_DATA=""

WORKDIR /src
COPY . /src
COPY test-docker/test.sh /src

RUN test -e test-docker/ && rm -rf test-docker/

RUN apk add gcc make python3-dev musl-dev linux-headers

# create environment to install requirements
RUN python -m venv addon-env
ENV PATH="/src/addon-env/bin:$PATH"
RUN test -e requirements.txt && pip3 install -r requirements.txt || echo "No requirements.txt"

# run tests if NC_TEST_DATA is set to NC with downloaded NC test loaction otherwise in empty location
RUN grass -c epsg:3358 /grassdb/nc_spm_empty --exec bash test.sh ${NC_TEST_DATA}
