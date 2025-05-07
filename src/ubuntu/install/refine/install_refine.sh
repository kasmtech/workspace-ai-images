#!/bin/bash

refine_version=${REFINE_VERSION:-"3.9.3"}

cd /opt
wget -O refine.tar.gz "https://openrefine.org/post_download?version=${refine_version}&platform=linux"
tar xzf refine.tar.gz
rm refine.tar.gz

chown -R 1000:0 /opt/refine
