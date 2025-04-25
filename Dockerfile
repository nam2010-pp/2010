FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt update && apt install -y \
  xfce4 xfce4-goodies tightvncserver x11vnc \
  novnc websockify xterm supervisor wget curl \
  fonts-dejavu ca-certificates locales && \
  locale-gen en_US.UTF-8

# Cài Firefox thủ công (không Snap)
RUN mkdir -p /opt/firefox && \
  curl -L "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" \
  -o /tmp/firefox.tar.bz2 && \
  tar -xjf /tmp/firefox.tar.bz2 -C /opt/firefox --strip-components=1 && \
  ln -s /opt/firefox/firefox /usr/local/bin/firefox && \
  rm /tmp/firefox.tar.bz2

# Tạo mật khẩu VNC mặc định là 123456
RUN mkdir -p /root/.vnc && \
  echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
  chmod 600 /root/.vnc/passwd && \
  echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /root/.vnc/xstartup && \
  chmod +x /root/.vnc/xstartup

# Copy cấu hình supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
