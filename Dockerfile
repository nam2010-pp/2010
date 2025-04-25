FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root

# Cập nhật hệ thống và cài các gói cần thiết
RUN apt update && apt install -y \
  xfce4 xfce4-goodies tightvncserver x11vnc \
  novnc websockify curl xterm wget net-tools \
  supervisor

# Tạo thư mục Firefox và cài đặt thủ công
RUN mkdir -p /opt/firefox && \
  curl -L -o /tmp/firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
  file /tmp/firefox.tar.bz2 | grep -q "bzip2 compressed data" && \
  tar -xjf /tmp/firefox.tar.bz2 -C /opt/firefox --strip-components=1 && \
  ln -s /opt/firefox/firefox /usr/local/bin/firefox && \
  rm /tmp/firefox.tar.bz2

# Tạo thư mục VNC
RUN mkdir -p ~/.vnc

# Tạo file khởi động XFCE
RUN echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > ~/.vnc/xstartup && \
  chmod +x ~/.vnc/xstartup

# Tạo mật khẩu VNC: 123456
RUN echo "123456" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd

# Tạo icon Firefox
RUN mkdir -p ~/.local/share/applications && \
  echo '[Desktop Entry]\nVersion=1.0\nName=Firefox\nGenericName=Web Browser\nExec=firefox %u\nIcon=firefox\nTerminal=false\nType=Application\nCategories=Network;WebBrowser;' > ~/.local/share/applications/firefox.desktop

# Tạo file khởi động giám sát VNC + noVNC
COPY supervisord.conf /etc/supervisord.conf

# Mở cổng VNC + noVNC (5901 + 8080)
EXPOSE 5901 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
