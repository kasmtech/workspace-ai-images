#!/bin/bash

tabula_version=${TABULA_VERSION:-"1.2.1"}

apt-get update
apt-get install -y unzip

cd /opt
wget -O tabula.zip "https://github.com/tabulapdf/tabula/releases/download/v${tabula_version}/tabula-jar-${tabula_version}.zip"
unzip "tabula.zip"

chown -R 1000:0 /opt/tabula


tabula_logo=/opt/tabula/webapp/modules/core/images/logo-gem-126.png
cat >/usr/share/applications/tabula.desktop<<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=tabula
GenericName=Data Transformation Tool
Comment=Data Transformation tool
Icon=${tabula_logo}
Path="/opt/tabula"
Exec="/opt/tabula/tabula"
Terminal=false
MimeType=application/x-extension-ows;
Categories=Science;Education;ArtificialIntelligence;DataVisualization;NumericalAnalysis;Java;
Keywords=Scientific Visualization;Statistical Analysis;
EOL
chmod +x /usr/share/applications/tabula.desktop
chown kasm-user:kasm-user /usr/share/applications/tabula.desktop
ln -s /usr/share/applications/tabula.desktop "$HOME/Desktop/tabula.desktop"

if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/*
fi