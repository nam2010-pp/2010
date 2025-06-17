FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1

# Cập nhật và cài GUI, VNC, noVNC, Firefox không snap, Playit, Supervisor
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    xterm novnc websockify wget curl gnupg2 lsb-release \
    supervisor locales xorg openbox x11-xserver-utils

# Cài Playit
RUN curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor -o /usr/share/keyrings/playit.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > /etc/apt/sources.list.d/playit-cloud.list && \
    apt update && apt install -y playit

# Cài Firefox từ Mozilla (không dùng snap)
RUN curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg | gpg --dearmor -o /usr/share/keyrings/mozilla.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mozilla.gpg] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list && \
    apt update && apt install -y firefox

# Tạo shortcut Firefox
RUN mkdir -p /root/.local/share/applications && \
    printf "[Desktop Entry]\nVersion=1.0\nName=Firefox\nGenericName=Web Browser\nExec=firefox %%u\nIcon=firefox\nTerminal=false\nType=Application\nCategories=Network;WebBrowser;\n" \
    > /root/.local/share/applications/firefox.desktop

# Cấu hình VNC + tự động khởi động Firefox
RUN mkdir -p /root/.vnc && \
    yes 123456 | vncpasswd && \
    chmod 600 /root/.vnc/passwd && \
    echo '#!/bin/bash\nstartxfce4 &\nsleep 5 && firefox &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Thêm supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
