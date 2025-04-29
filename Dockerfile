FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1

# Cập nhật và cài gói cần thiết
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    xterm novnc websockify wget curl gnupg2 supervisor locales firefox && \
    locale-gen en_US.UTF-8

# Tạo file Xresources cho xrdb
RUN touch /root/.Xresources

# Tạo thư mục cấu hình VNC
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &\nsleep 5 && firefox &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Tạo shortcut Firefox trong menu XFCE
RUN mkdir -p /root/.local/share/applications && \
    echo "[Desktop Entry]
Version=1.0
Name=Firefox
GenericName=Web Browser
Exec=firefox %u
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;" > /root/.local/share/applications/firefox.desktop

# Copy file cấu hình Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
