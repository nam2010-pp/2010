FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1

# Cài GUI, VNC, noVNC, Firefox
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    xterm novnc websockify wget curl gnupg2 lsb-release supervisor locales \
    xorg openbox x11-xserver-utils git

# Cài Playit
RUN curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor -o /usr/share/keyrings/playit.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > /etc/apt/sources.list.d/playit-cloud.list && \
    apt update && apt install -y playit

# Cài Firefox từ Mozilla (không dùng snap)
RUN curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg | gpg --dearmor -o /usr/share/keyrings/mozilla.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mozilla.gpg] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list && \
    apt update && apt install -y firefox
    git clone https://github.com/nam2010-pp/NodeJS-DuinoCoin-Miner

# Tạo shortcut Firefox
RUN mkdir -p /root/.local/share/applications && \
    echo '[Desktop Entry]\nVersion=1.0\nName=Firefox\nGenericName=Web Browser\nExec=firefox %u\nIcon=firefox\nTerminal=false\nType=Application\nCategories=Network;WebBrowser;' > /root/.local/share/applications/firefox.desktop

# Cấu hình VNC + tự động khởi động Firefox
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo '#!/bin/bash\nstartxfce4 &\nsleep 5 && firefox &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
