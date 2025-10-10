#/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Show header
show_header() {
    clear
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}      Docker Management Tool        ${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo -e "  Features: Reinstall / Configure / Verify"
    echo -e "  For: Ubuntu 18.04"
    echo -e "  ${YELLOW}Type 'q' to exit${NC}\n"
}

# Show main menu
show_menu() {
    echo -e "${YELLOW}Select an option:${NC}"
    echo -e "  1. ${GREEN}Reinstall Docker${NC} (Full cleanup & fresh install)"
    echo -e "  2. ${GREEN}Update CA Certificates${NC} (Fix certificate issues)"
    echo -e "  3. ${GREEN}Configure Registry Mirrors${NC} (Add acceleration mirrors)"
    echo -e "  4. ${GREEN}Verify Installation${NC} (Run hello-world test)"
    echo -e "  q. ${RED}Exit tool${NC}"
    echo -en "\n${YELLOW}Enter option: ${NC}"
}

# Confirm action
confirm() {
    local action=$1
    echo -e "\n${YELLOW}About to: ${action} (may take several minutes)...${NC}"
    read -p "Proceed? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Show result
show_result() {
    local status=$1
    local msg=$2
    if [ $status -eq 0 ]; then
        echo -e "\n${GREEN}✅ Success: ${msg}${NC}"
    else
        echo -e "\n${RED}❌ Failed: ${msg}${NC}"
    fi
    read -p "Press Enter to return to menu..."
}

reinstallDorcker() {
	sudo apt-get purge docker-ce docker-ce-cli containerd.io
	sudo rm -rf /var/lib/docker
	sudo rm -rf /etc/docker
	sudo rm -rf /lib/systemd/system/docker.service

	# 删除核心程序和配置
	sudo rm -rf /usr/bin/docker /usr/bin/docker-containerd /usr/bin/docker-runc
	sudo rm -rf /etc/docker /etc/default/docker /etc/init.d/docker
	sudo rm -rf /var/lib/docker /var/run/docker.sock /var/log/docker

	# 删除 dpkg 数据库中的残留记录（关键步骤）
	sudo rm -f /var/lib/dpkg/info/docker.io.*  # 包括 prerm、postinst 等脚本
	sudo rm -f /var/lib/dpkg/status.d/docker.io
	sudo dpkg --remove --force-remove-reinstreq docker.io  # 最后尝试清理状态
	sudo apt-get autoremove -y
	sudo apt-get autoclean

	sudo apt-get update

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

	# 此处不同的ubuntu版本不同，目前宿主机版本ubuntu18.04
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt-get update
	sudo apt-get install -y moby-engine moby-cli moby-containerd
	sudo apt-get install docker-ce docker-ce-cli containerd.io

	# 启动并设置自启
	sudo usermod -aG docker $USER
	sudo systemctl start docker
	sudo systemctl enable docker
}

updateCA() {
	sudo apt-get update
	sudo apt-get install --reinstall ca-certificates
	sudo update-ca-certificates --fresh
}

addDockerRegistryMirror() {
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.nju.edu.cn",
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://docker.mirrors.ustc.edu.cn",
    "https://mirror.baidubce.com",
    "https://dockerproxy.com",
    "https://1i6z9fqv.mirror.aliyuncs.com",
    "https://hub-mirror.c.163.com"
  ],
  "insecure-registries": [
    "registry.docker-cn.com",
    "docker.mirrors.ustc.edu.cn"
  ],
  "debug": true,
  "experimental": false
}
EOF
}

verifyInstall() {
	sudo docker pull hello-world
	sudo docker run hello-world
}

# Main program
main() {
    trap 'echo -e "\n${RED}Tool terminated${NC}"; exit 0' SIGINT

    while true; do
        show_header
        show_menu
        read -r choice

        case $choice in
            1)
                if confirm "Reinstall Docker"; then
                    reinstallDorcker
                    show_result $? "Docker reinstalled (re-login for user group changes)"
                else
                    echo -e "${YELLOW}Action cancelled${NC}"
                    read -p "Press Enter to continue..."
                fi
                ;;
            2)
                if confirm "Update CA Certificates"; then
                    updateCA
                    show_result $? "CA certificates updated"
                else
                    echo -e "${YELLOW}Action cancelled${NC}"
                    read -p "Press Enter to continue..."
                fi
                ;;
            3)
                if confirm "Configure Registry Mirrors"; then
                    addDockerRegistryMirror
                    show_result $? "Registry mirrors configured"
                else
                    echo -e "${YELLOW}Action cancelled${NC}"
                    read -p "Press Enter to continue..."
                fi
                ;;
            4)
                echo -e "\n${YELLOW}Verifying installation...${NC}"
                verifyInstall
                show_result $? "hello-world test completed"
                ;;
            q|Q)
                echo -e "\n${BLUE}Thank you for using, goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}Invalid option! Enter 1-4 or q${NC}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

main
