INSTALL() {
  curl -L https://github.com/xhofe/alist/releases/latest/download/alist-linux-amd64.tar.gz -o /tmp/alist-linux-amd64.tar.gz
  tar zxf /tmp/alist-linux-amd64.tar.gz -C /opt/alist
  rm -f /tmp/alist*
}
INIT() {
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


  systemctl daemon-reload
  systemctl enable alist >/dev/null 2>&1
}
