#!/bin/bash

set -x

echo "Copy files from pre-load directory into home"
cp --update -r -v /pre-home/. /home/jovyan
rm -rf /pre-home/git
git clone https://github.com/martindurant/pangeo-example-notebooks /pre-home/git
cd /pre-home/git
DATESTAMP=`git log -1 --format=%cd --date=short`
for file in  *.ipynb; do cp --update "$file" /home/jovyan/examples/"${file/.ipynb/_$DATESTAMP.ipynb}"; done
touch /home/jovyan/examples/PROVIDED_EXAMPLE_NOTEBOOKS.md
cd

if [ -e "/opt/app/environment.yml" ]; then
    echo "environment.yml found. Installing packages"
    /opt/conda/bin/conda env update -f /opt/app/environment.yml
else
    echo "no environment.yml"
fi

if [ "$EXTRA_CONDA_PACKAGES" ]; then
    echo "EXTRA_CONDA_PACKAGES environment variable found.  Installing."
    /opt/conda/bin/conda install $EXTRA_CONDA_PACKAGES
fi

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing".
    /opt/conda/bin/pip install $EXTRA_PIP_PACKAGES
fi

if [ "$GCSFUSE_BUCKET" ]; then
    echo "Mounting $GCSFUSE_BUCKET to /gcs"
    /opt/conda/bin/gcsfuse $GCSFUSE_BUCKET /gcs --background
fi
# Run extra commands
$@
