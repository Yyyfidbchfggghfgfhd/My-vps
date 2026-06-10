FROM ubuntu:22.04

# Cài đặt dependencies đầy đủ
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    wget curl git \
    xvfb \
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    dbus-x11 \
    python3 \
    websockify \
    && apt clean

# Tải noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    tar -xzf v1.2.0.tar.gz && \
    rm v1.2.0.tar.gz && \
    mv noVNC-1.2.0 /novnc

# Cấu hình VNC
RUN mkdir -p /root/.vnc && \
    echo 'xt' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

RUN echo '#!/bin/bash' > /root/.vnc/xstartup && \
    echo 'xfce4-session &' >> /root/.vnc/xstartup && \
    chmod 755 /root/.vnc/xstartup

# Script khởi động
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'export DISPLAY=:0' >> /start.sh && \
    echo 'Xvfb :0 -screen 0 1024x768x24 &' >> /start.sh && \
    echo 'sleep 3' >> /start.sh && \
    echo 'vncserver :0 -geometry 1024x768 -depth 24 -localhost no' >> /start.sh && \
    echo 'sleep 2' >> /start.sh && \
    echo 'cd /novnc && ./utils/launch.sh --vnc localhost:5900 --listen 10000' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 10000
CMD /start.sh
