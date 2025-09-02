#!/bin/bash

weka_version=${WEKA_VERSION:-"3.9.6"}

apt-get update
apt-get install -y unzip

cd /opt
wget -O weka.zip "https://prdownloads.sourceforge.net/weka/weka-${weka_version//\./-}-azul-zulu-linux.zip"
unzip "weka.zip"
mv "/opt/weka-${weka_version//\./-}" /opt/weka
rm -rf /opt/weka/jre

cp "$(dirname "$0")/weka.sh" /opt/weka/
cp "$(dirname "$0")/weka.ico" /opt/weka/

chown -R 1000:0 /opt/weka


weka_logo=/opt/weka/weka.ico
cat >/usr/share/applications/weka.desktop<<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=weka
GenericName=Data Transformation Tool
Comment=Data Transformation tool
Icon=${weka_logo}
Path="/opt/weka"
Exec="/opt/weka/weka.sh"
Terminal=false
MimeType=application/x-extension-ows;
Categories=Science;Education;ArtificialIntelligence;DataVisualization;NumericalAnalysis;Java;
Keywords=Scientific Visualization;Statistical Analysis;
EOL
chmod +x /usr/share/applications/weka.desktop
chown kasm-user:kasm-user /usr/share/applications/weka.desktop
ln -s /usr/share/applications/weka.desktop "$HOME/Desktop/weka.desktop"

if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/*
fi