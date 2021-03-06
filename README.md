



### Checking bolt
bolt inventory show --targets <TARGET LIST> --detail


### lxc error (apparmor)
lxc list
cat: /proc/self/attr/current: Permission denied
/snap/lxd/19188/commands/lxc: 6: exec: aa-exec: Permission denied

Try:

find /var/lib/snapd/apparmor/profiles/snap.lxd.* -type f -exec sed -i 's|/usr/sbin/aa-exec ux,|/usr/bin/aa-exec ux,|g' {} \;
apparmor_parser -r /var/lib/snapd/apparmor/profiles/* -v

systemctl stop snap.lxd.daemon.unix.socket
systemctl stop snap.lxd.daemon.service
systemctl start snap.lxd.daemon.unix.socket
systemctl start snap.lxd.daemon.service
systemctl status snap.lxd.daemon.unix.socket
systemctl status snap.lxd.daemon.service



debug
#systemctl status snapd.seeded.service
service snapd stop
apt purge snapd
apt install snapd

bolt 