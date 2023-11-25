#!/bin/bash

cat >/etc/init.d/nezha-agent <<EOF
#!/sbin/openrc-run
SERVER="nezha.zumba.eu.org:443" #Dashboard 地址 ip:port
SECRET="Ti49uxFLLjceUAiRy6" #SECRET
TLS="--tls" # 是否启用 tls 是 "--tls" 否留空
NZ_BASE_PATH="/opt/nezha"
NZ_AGENT_PATH="\${NZ_BASE_PATH}/agent"
pidfile="/run/\${RC_SVCNAME}.pid"
command="/opt/nezha/agent/nezha-agent"
command_args="-s \${SERVER} -p \${SECRET} \${TLS}"
command_background=true
depend() {
	need net
}
checkconfig() {
	GITHUB_URL="github.com"
	if [ ! -f "\${NZ_AGENT_PATH}/nezha-agent" ]; then
		if [[ \$(uname -m | grep 'x86_64') != "" ]]; then
			os_arch="amd64"
		elif [[ \$(uname -m | grep 'i386\|i686') != "" ]]; then
			os_arch="386"
		elif [[ \$(uname -m | grep 'aarch64\|armv8b\|armv8l') != "" ]]; then
			os_arch="arm64"
		elif [[ \$(uname -m | grep 'arm') != "" ]]; then
			os_arch="arm"
		elif [[ \$(uname -m | grep 's390x') != "" ]]; then
			os_arch="s390x"
		elif [[ \$(uname -m | grep 'riscv64') != "" ]]; then
			os_arch="riscv64"
		fi
		local version=\$(curl -m 10 -sL "https://api.github.com/repos/nezhahq/agent/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print \$2}' | sed 's/\"//g;s/,//g;s/ //g')
		if [ ! -n "\$version" ]; then
			version=\$(curl -m 10 -sL "https://fastly.jsdelivr.net/gh/nezhahq/agent/" | grep "option\.value" | awk -F "'" '{print \$2}' | sed 's/nezhahq\/agent@/v/g')
		fi
		if [ ! -n "\$version" ]; then
			version=\$(curl -m 10 -sL "https://gcore.jsdelivr.net/gh/nezhahq/agent/" | grep "option\.value" | awk -F "'" '{print \$2}' | sed 's/nezhahq\/agent@/v/g')
		fi
		if [ ! -n "\$version" ]; then
			echo -e "获取版本号失败，请检查本机能否链接 https://api.github.com/repos/nezhahq/agent/releases/latest"
			return 0
		else
			echo -e "当前最新版本为: \${version}"
		fi
		wget -t 2 -T 10 -O nezha-agent_linux_\${os_arch}.zip https://\${GITHUB_URL}/nezhahq/agent/releases/download/\${version}/nezha-agent_linux_\${os_arch}.zip >/dev/null 2>&1
		if [[ \$? != 0 ]]; then
			echo -e "Release 下载失败，请检查本机能否连接 \${GITHUB_URL}\${plain}"
			return 0
		fi
		mkdir -p \$NZ_AGENT_PATH
		chmod 755 -R \$NZ_AGENT_PATH
		unzip -qo nezha-agent_linux_\${os_arch}.zip && mv nezha-agent \$NZ_AGENT_PATH && rm -rf nezha-agent_linux_\${os_arch}.zip README.md
	fi
	if [ ! -x "\${NZ_AGENT_PATH}/nezha-agent" ]; then
		chmod +x \${NZ_AGENT_PATH}/nezha-agent
	fi
}
start_pre() {
	if [ "\${RC_CMD}" != "restart" ]; then
		checkconfig || return \$?
	fi
}
EOF

# Save the file
chmod +x /etc/init.d/nezha-agent

# Start the service and add it to startup
rc-service nezha-agent start
rc-update add nezha-agent
