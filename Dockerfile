FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Chuyển source về old-releases do Ubuntu 20.04 đã hết hạn chính thức
RUN sed -i 's|http://.*.ubuntu.com|http://old-releases.ubuntu.com|g' /etc/apt/sources.list

# Cập nhật & cài GUI, VNC, Firefox (non-snap), Playit, Supervisor
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    xterm novnc websockify wget curl gnupg2 lsb-release \
    supervisor locales xorg openbox x11-xserver-utils dbus-x11

# Cấu hình ngôn ngữ mặc định
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

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

# Cấu hình VNC + tự khởi động Firefox
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    printf '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &\nsleep 5 && firefox &\n' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Thêm file cấu hình supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
