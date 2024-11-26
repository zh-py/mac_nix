iwctl adapter phy0 set-property Powered on
iwctl device eth0 set-property Powered on
/etc/profiles/per-user/py/bin/fusuma -d
keyd-application-mapper -d

exec startlxqt
