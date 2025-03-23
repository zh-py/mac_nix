iwctl adapter phy0 set-property Powered on
iwctl device eth0 set-property Powered on

systemctl --user start libinput-gestures

exec startlxqt

