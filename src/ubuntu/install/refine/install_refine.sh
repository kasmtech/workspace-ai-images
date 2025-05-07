#!/bin/bash

refine_version=${REFINE_VERSION:-"3.9.3"}

cd /opt
wget -O refine.tar.gz "https://github.com/OpenRefine/OpenRefine/releases/download/${refine_version}/openrefine-linux-${refine_version}.tar.gz"
tar xzf refine.tar.gz
mv "openrefine-${refine_version}" "openrefine"
rm refine.tar.gz

chown -R 1000:0 /opt/openrefine
