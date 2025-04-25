# Dockerfile
FROM ubuntu:22.04

# Không hiển thị prompt chọn vùng/locale
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 1) Cài các gói cơ bản
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    xterm wget curl git supervisor locales \
    ca-certificates xz-utils && \
    locale-gen en_US.UTF-8

# 2) Cài Firefox thủ công (không qua Snap)
RUN mkdir -p /opt/firefox && \
    wget -O /tmp/firefox.tar.bz2 \
      "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    tar -xjf /tmp/firefox.tar.bz2 -C /opt/firefox --strip-components=1 && \
    ln -s /opt/firefox/firefox /usr/local/bin/firefox && \
    rm /tmp/firefox.tar.bz2

# 3) Thiết lập mật khẩu VNC (123456) và xstartup
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    printf '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' \
      > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# 4) Copy cấu hình Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 5) Expose noVNC port
EXPOSE 8080

# 6) Start Supervisor để quản lý VNC + x11vnc + noVNC
CMD ["/usr/bin/supervisord", "-n"]
