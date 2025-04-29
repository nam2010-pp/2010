FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1

# Cập nhật và cài đặt gói cần thiết
RUN apt update && apt install -y \
    xfce4 xfce4-goodies tightvncserver x11vnc \
    xterm novnc websockify wget curl gnupg2 supervisor locales firefox && \
    locale-gen en_US.UTF-8

# Tạo file Xresources cho xrdb
RUN touch /root/.Xresources

# Cấu hình VNC và khởi động Firefox trong XFCE
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &\nsleep 5 && firefox &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Sửa lỗi Firefox không lên khi click icon
RUN mkdir -p /root/.local/share/applications && \
    cat > /root/.local/share/applications/firefox.desktop <<EOF
[Desktop Entry]
Version=1.0
Name=Firefox
GenericName=Web Browser
Exec=env DISPLAY=:1 firefox %u
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF

# Gắn DISPLAY vào bashrc để các tiến trình phụ nhận diện
RUN echo 'export DISPLAY=:1' >> /root/.bashrc

# Copy file cấu hình supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
