#!/bin/bash

refine_version=${REFINE_VERSION:-"3.9.3"}

cd /opt
wget -O refine.tar.gz "https://github.com/OpenRefine/OpenRefine/releases/download/${refine_version}/openrefine-linux-${refine_version}.tar.gz"
tar xzf refine.tar.gz
mv "openrefine-${refine_version}" "openrefine"
rm refine.tar.gz

cd openrefine
cp refine refine.bak
patch -f -p0 < "$(dirname "$0")/refine.patch"

refine_logo=/opt/openrefine/webapp/modules/core/images/logo-gem-126.png

chown -R 1000:0 /opt/openrefine


cat >/usr/share/applications/openrefine.desktop<<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=OpenRefine
GenericName=Data Transformation Tool
Comment=Data Transformation tool
Icon=${refine_logo}
Path="/opt/openrefine"
Exec="/opt/openrefine/refine"
Terminal=false
MimeType=application/x-extension-ows;
Categories=Science;Education;ArtificialIntelligence;DataVisualization;NumericalAnalysis;Java;
Keywords=Scientific Visualization;Statistical Analysis;
EOL
chmod +x /usr/share/applications/openrefine.desktop
chown kasm-user:kasm-user /usr/share/applications/openrefine.desktop
ln -s /usr/share/applications/openrefine.desktop "$HOME/Desktop/openrefine.desktop"
