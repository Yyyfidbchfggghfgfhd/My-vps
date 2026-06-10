FROM alpine:latest

# Cài đặt Wine và dependencies
RUN apk add --no-cache \
    wget curl bash \
    wine xvfb xfce4 xfce4-terminal tightvnc \
    xrdp dbus dbus-x11 \
    && rm -rf /var/cache/apk/*

# Cấu hình Wine với Windows 7
RUN winecfg -v win7 || true

# Tạo Windows 7 disk image (nếu cần)
RUN mkdir -p /root/.wine/drive_c

# noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    tar -xzf v1.2.0.tar.gz && rm v1.2.0.tar.gz

# Cấu hình VNC
RUN mkdir -p $HOME/.vnc && \
    echo 'xt' | vncpasswd -f > $HOME/.vnc/passwd && \
    chmod 600 $HOME/.vnc/passwd

# Tạo xstartup cho VNC
RUN echo '#!/bin/sh' > $HOME/.vnc/xstartup && \
    echo 'xfce4-session &' >> $HOME/.vnc/xstartup && \
    echo 'sleep 2' >> $HOME/.vnc/xstartup && \
    echo 'wine explorer /desktop=shell,1360x768 &' >> $HOME/.vnc/xstartup && \
    chmod 755 $HOME/.vnc/xstartup

# Script khởi động chính
RUN echo '#!/bin/sh' > /start.sh && \
    echo '#!/bin/sh' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Khởi tạo D-Bus' >> /start.sh && \
    echo 'mkdir -p /var/run/dbus' >> /start.sh && \
    echo 'dbus-daemon --system --fork' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Khởi động Xvfb (display ảo)' >> /start.sh && \
    echo 'Xvfb :0 -screen 0 1360x768x24 &' >> /start.sh && \
    echo 'export DISPLAY=:0' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Khởi động VNC server' >> /start.sh && \
    echo 'vncserver :1 -geometry 1360x768 -localhost no -display :0' >> /start.sh || true >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Khởi động noVNC' >> /start.sh && \
    echo 'cd /noVNC-1.2.0 && ./utils/launch.sh --vnc localhost:5901 --listen 8900 &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Khởi động XRDP' >> /start.sh && \
    echo 'xrdp --nodaemon &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "======================================"' >> /start.sh && \
    echo 'echo "=== Windows 7 Lite via Wine ==="' >> /start.sh && \
    echo 'echo "======================================"' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "📱 Truy cập Windows 7 GUI:"' >> /start.sh && \
    echo 'echo "   http://localhost:8900/vnc.html"' >> /start.sh && \
    echo 'echo "   Password VNC: xt"' >> /start.sh && \
    echo 'echo "   Mật khẩu: xt"' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "🔧 Cổng kết nối:"' >> /start.sh && \
    echo 'echo "   Web: http://localhost:8900"' >> /start.sh && \
    echo 'echo "   VNC: localhost:5901"' >> /start.sh && \
    echo 'echo "   RDP: localhost:3389"' >> /start.sh && \
    echo 'echo "======================================"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Giữ container chạy' >> /start.sh && \
    echo 'tail -f /dev/null' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8900 5901 3389
CMD /start.sh
