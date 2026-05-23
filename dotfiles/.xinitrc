iwctl adapter phy0 set-property Powered on
iwctl device eth0 set-property Powered on

dbus-update-activation-environment --all
(sleep 3 && systemctl --user start libinput-gestures) &

exec startlxqt
