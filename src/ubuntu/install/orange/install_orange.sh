#!/bin/bash
set -ex
mkdir -p /opt/orange
cp "$(dirname "$0")/orange-canvas.png" /opt/orange
chown -R 1000:0 /opt/orange
chown kasm-user:kasm-user "$(dirname "$0")/install_orange_as_user.sh"
chmod +x "$(dirname "$0")/install_orange_as_user.sh"
/bin/su -c "HOME=/home/kasm-default-profile $(dirname "$0")/install_orange_as_user.sh" kasm-user

# https://github.com/biolab/orange3/blob/master/distribute/orange-canvas.png

cat >"/opt/orange/launch_orange.sh"<<EOL
#!/bin/bash
cd "/opt/orange"
python -m Orange.canvas "$@"
EOL
chmod +x "/opt/orange/launch_orange.sh"
chown kasm-user:kasm-user "/opt/orange/launch_orange.sh"

cat >/usr/share/applications/orange.desktop<<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Orange Data Mining
GenericName=Data Mining Suite
Comment=Explore, analyze, and visualize your data
Icon=/opt/orange/orange-canvas.png
Path="/home/kasm-user/orange"
Exec="/home/kasm-user/orange/launch_orange.sh" %f
Terminal=false
MimeType=application/x-extension-ows;
Categories=Science;Education;ArtificialIntelligence;DataVisualization;NumericalAnalysis;Qt;
Keywords=Machine Learning;Scientific Visualization;Statistical Analysis;
EOL
chmod +x /usr/share/applications/orange.desktop
chown kasm-user:kasm-user /usr/share/applications/orange.desktop

