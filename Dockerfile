FROM ubuntu:22.04

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    wget curl git xz-utils dbus-x11 \
    xfce4 xfce4-terminal tightvncserver \
    firefox gnome-system-monitor mate-system-monitor \
    wine qemu-kvm && \
    apt clean

RUN dpkg --add-architecture i386 && \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y wine32 && \
    apt clean

RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    tar -xvf v1.2.0.tar.gz && \
    rm v1.2.0.tar.gz

RUN mkdir -p $HOME/.vnc && \
    echo 'xt' | vncpasswd -f > $HOME/.vnc/passwd && \
    chmod 600 $HOME/.vnc/passwd

RUN echo '/bin/env MOZ_FAKE_NO_SANDBOX=1 dbus-launch xfce4-session' > $HOME/.vnc/xstartup && \
    chmod 755 $HOME/.vnc/xstartup

RUN echo '#!/bin/bash' > /luo.sh && \
    echo 'whoami' >> /luo.sh && \
    echo 'cd' >> /luo.sh && \
    echo "su -l -c 'vncserver :2000 -geometry 1360x768'" >> /luo.sh && \
    echo 'cd /noVNC-1.2.0' >> /luo.sh && \
    echo './utils/launch.sh --vnc localhost:7900 --listen 8900' >> /luo.sh && \
    chmod 755 /luo.sh

EXPOSE 8900
CMD /start.sh
