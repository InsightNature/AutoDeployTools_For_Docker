FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=quectel

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  

RUN echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc

RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:123456" | chpasswd && \
    usermod -aG sudo $USER
