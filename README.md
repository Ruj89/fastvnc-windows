On the client side install putty and configure and save a session to access the remote vnc server.

On the server side:

```bash
/home/<user>/.vnc/xstartup

#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -nowin &

```

``` bash
/etc/systemd/system/vncserver@.service

[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=<user>
Group=<user>
WorkingDirectory=/home/<user>

PIDFile=/home/<user>/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1366x768 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target

```

```bash
sudo apt install xfce4
chmod 775 /home/<user>/.vnc/xstartup
sudo chmod 775 /etc/systemd/system/vncserver@.service
sudo systemctl enable vncserver@1
vncpasswd
```

Reboot
