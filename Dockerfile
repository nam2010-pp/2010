FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1

# Cài GUI, VNC, noVNC, Firefox (từ apt)
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    xterm novnc websockify wget curl gnupg2 lsb-release supervisor locales \
    xorg openbox x11-xserver-utils git firefox

# Cài Playit
RUN curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor -o /usr/share/keyrings/playit.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > /etc/apt/sources.list.d/playit-cloud.list && \
    apt update && apt install -y playit

# Clone project NodeJS miner (tuỳ chỉnh tuỳ ông)
RUN git clone https://github.com/nam2010-pp/miner /root/miner

# Shortcut Firefox
RUN mkdir -p /root/.local/share/applications && \
    echo '[Desktop Entry]\nVersion=1.0\nName=Firefox\nGenericName=Web Browser\nExec=firefox %u\nIcon=firefox\nTerminal=false\nType=Application\nCategories=Network;WebBrowser;' > /root/.local/share/applications/firefox.desktop

# Thiết lập VNC + tự động mở Firefox
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo '#!/bin/bash\nstartxfce4 &\nsleep 5 && firefox &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Copy file giám sát
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
