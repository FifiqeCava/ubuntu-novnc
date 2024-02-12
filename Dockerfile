FROM ubuntu:18.04
MAINTAINER uli.hitzel@gmail.com
EXPOSE 8080 5901
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Singapore

RUN apt-get update
RUN apt-get install -y xfce4 xfce4-terminal
RUN apt-get install -y novnc
RUN apt-get install -y tightvncserver websockify
RUN apt-get install -y wget net-tools wget curl chromium-browser firefox openssh-client git
ENV USER root
#RUN printf "axway99\naxway99\n\n" | vncserver :1

COPY start.sh /start.sh
RUN chmod a+x /start.sh

RUN useradd -ms /bin/bash user
RUN mkdir /.novnc
RUN chown user:user /.novnc

COPY config /home/user
RUN chown -R user:user /home/user
USER root

WORKDIR /.novnc
RUN wget -qO- https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz | tar xz --strip 1 -C $PWD
RUN mkdir /.novnc/utils/websockify
RUN wget -qO- https://github.com/novnc/websockify/archive/v0.6.1.tar.gz | tar xz --strip 1 -C /.novnc/utils/websockify
RUN ln -s vnc.html index.html

USER 0
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=dummy
RUN dpkg --add-architecture i386
RUN apt-get update
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
RUN apt-get install -y software-properties-common
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
RUN apt-get update
RUN apt-get install -y --install-recommends winehq-stable

USER root
WORKDIR /home/user

CMD ["sh","/start.sh"]
