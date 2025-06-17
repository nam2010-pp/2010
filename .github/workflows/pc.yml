FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Cập nhật và cài gói cần thiết
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    xterm novnc websockify wget curl gnupg2 lsb-release supervisor locales \
    xorg openbox x11-xserver-utils git firefox dbus-x11

# Cấu hình locale
RUN locale-gen en_US.UTF-8

# Cài Playit
RUN curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor -o /usr/share/keyrings/playit.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > /etc/apt/sources.list.d/playit-cloud.list && \
    apt update && apt install -y playit

# Clone NodeJS miner (tùy bạn chỉnh link)
RUN git clone https://github.com/nam2010-pp/miner /root/miner

# Tạo shortcut Firefox
RUN mkdir -p /root/.local/share/applications && \
    echo '[Desktop Entry]\nVersion=1.0\nName=Firefox\nGenericName=Web Browser\nExec=firefox %u\nIcon=firefox\nTerminal=false\nType=Application\nCategories=Network;WebBrowser;' > /root/.local/share/applications/firefox.desktop

# Thiết lập VNC
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &\nsleep 5 && firefox &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Copy cấu hình giám sát
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Mở cổng noVNC
EXPOSE 8080

# Chạy supervisord
CMD ["/usr/bin/supervisord", "-n"]
