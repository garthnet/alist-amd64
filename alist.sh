#!/bin/bash

# Download alist binary
curl -L https://github.com/xhofe/alist/releases/latest/download/alist-linux-amd64.tar.gz -o /tmp/alist-linux-amd64.tar.gz

# Create directory and extract files
mkdir /opt/alist
tar zxf /tmp/alist-linux-amd64.tar.gz -C /opt/alist

# Clean up temporary files
rm -f /tmp/alist*

# Create systemd service file
cat >/etc/systemd/system/alist.service <<EOF
[Unit]
Description=Alist service
Wants=network.target
After=network.target network.service

[Service]
Type=simple
WorkingDirectory=/opt/alist
ExecStart=/opt/alist/alist server
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable the service, and start alist
systemctl daemon-reload
systemctl enable alist
systemctl start alist

# Change directory to /opt/alist and set alist admin
cd /opt/alist
./alist admin set 5244
