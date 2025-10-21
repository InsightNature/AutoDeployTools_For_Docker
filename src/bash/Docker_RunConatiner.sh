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

while true; do
    read -s -p "Set user password: " user_password
    echo
    read -s -p "Confirm user password: " user_password_confirm
    echo
    if [ "$user_password" = "$user_password_confirm" ]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

tee Dockerfile <<EOF > /dev/null
FROM $image_name

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=quectel

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  

RUN echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc

RUN if ! id -u \$USER >/dev/null 2>&1; then \
      useradd -m -s /bin/bash \$USER; \
    fi && \
    echo "\$USER:$user_password" | chpasswd && \
    usermod -aG sudo \$USER
EOF

new_image_name="${image_name}-with-user"
docker build -t $new_image_name .

rm -f Dockerfile

if [ "$sel" = "--mnt" ]; then
	docker run -it \
	  --privileged \
	  --name $container_name \
	  -v $container_file:/home/quectel/WorkSpace \
	  -v /opt:/opt \
	  -v $HOME/.ssh:/home/quectel/.ssh:ro \
	  -w /home/quectel/WorkSpace \
	  --user quectel \
	  $new_image_name \
	  /bin/bash

elif [ "$sel" = "--ssh" ]; then
	docker run -it \
	  --privileged \
	  --name $container_name \
	  -v $container_file:/home/quectel/WorkSpace \
	  -v $HOME/.ssh:/home/quectel/.ssh:ro \
	  -w /home/quectel/WorkSpace \
	  --user quectel \
	  $new_image_name \
	  /bin/bash
else
	docker run -it \
	  --privileged \
	  --name $container_name \
	  -v $container_file:/home/quectel/WorkSpace \
	  -w /home/quectel/WorkSpace \
	  --user quectel \
	  $new_image_name \
	  /bin/bash
fi
