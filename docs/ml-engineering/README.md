
# ML Engineering Workspace

Tools included:
1. OnlyOffice
2. [Orange Data Mining](https://orangedatamining.com/)
3. [OpenRefine](https://openrefine.org/)
4. [Weka](https://ml.cms.waikato.ac.nz/weka/)
5. VS Code with extensions:
    - [Data Wrangler](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.datawrangler) 
    - [Cline](https://marketplace.visualstudio.com/items?itemName=saoudrizwan.claude-dev)
6. Java JVM 17 (see [Adoptium](https://adoptium.net))

### Pre-configuring Workspace to autostart Orange for demo purposes

Create a **File Mapping** as follows:
* **Type** `Text`
* **Name** `Demo Config`
* **Description** `Demo Config`
* **Destination Path** `/dockerstartup/custom_startup/100-orange.once.sh`
* **Executable** Enabled
* **Writeable** Disabled

with the following content:
```shell
#!/bin/bash
/usr/bin/desktop_ready && /opt/orange/launch_orange.sh
```

Click `Save` and run workspace to confirm Orange launches on startup