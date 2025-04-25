FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1

# Cập nhật và cài các gói cần thiết
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    firefox xterm novnc websockify wget curl supervisor locales && \
    locale-gen en_US.UTF-8

# Tạo cấu hình VNC
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Tạo file khởi động VNC
RUN echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Copy file cấu hình Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Cổng noVNC sẽ chạy ở đây
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
