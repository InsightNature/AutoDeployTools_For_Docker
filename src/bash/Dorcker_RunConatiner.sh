#!/bin/bash

if [ $# -lt 3 ];
then
    echo "please input [container_name][container_file][image_name]"
    exit 1
fi


container_name=$1
container_file=$2
image_name=$3
sel="${4:-}"

tee $container_file/Container_Init.sh <<'EOF' > /dev/null
#!/bin/bash

apt-get update
apt-get install -y vim
apt-get install -y sudo

echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc
source /etc/bash.bashrc

useradd -m -s /bin/bash quectel
usermod -aG sudo quectel

passwd quectel
su quectel
rm -f "$0"
EOF

chmod +x $container_file/Container_Init.sh

if [ "$sel" = "--mnt" ]; then
	docker run -it \
	  --privileged \
	  --name $container_name \
	  -v $container_file:/home/quectel/WorkSpace \
	  -v /opt:/opt \
	  -v $HOME/.ssh:/home/quectel/.ssh:ro \
	  -w /home/quectel/WorkSpace \
	  $image_name \
	  /bin/bash
elif [ "$sel" = "--ssh" ]; then
	docker run -it \
	  --name $container_name \
	  -v $container_file:/home/quectel/WorkSpace \
	  -v $HOME/.ssh:/home/quectel/.ssh:ro \
	  -w /home/quectel/WorkSpace \
	  $image_name \
	  /bin/bash
else
	docker run -it \
	  --name $container_name \
	  -v $container_file:/home/quectel/WorkSpace \
	  -w /home/quectel/WorkSpace \
	  $image_name \
	  /bin/bash
fi
