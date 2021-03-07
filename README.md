
### lxc error (apparmor)
lxc list
cat: /proc/self/attr/current: Permission denied
/snap/lxd/19188/commands/lxc: 6: exec: aa-exec: Permission denied

This is because apparmor is enabled in the microk8s profile
Try:

```bash
find /var/lib/snapd/apparmor/profiles/snap.lxd.* -type f -exec sed -i 's|/usr/sbin/aa-exec ux,|/usr/bin/aa-exec ux,|g' {} \;
apparmor_parser -r /var/lib/snapd/apparmor/profiles/* -v
```

Suggested but - not needed:
systemctl stop snap.lxd.daemon.unix.socket
systemctl stop snap.lxd.daemon.service
systemctl start snap.lxd.daemon.unix.socket
systemctl start snap.lxd.daemon.service
systemctl status snap.lxd.daemon.unix.socket
systemctl status snap.lxd.daemon.service


### Problems with Unbuntu 20.10 and snap - stay on LTS 20.04
debug
#systemctl status snapd.seeded.service
service snapd stop
apt purge snapd
apt install snapd

### Puppet bolt - bolt would allow parallel operations in LXD nodes

Not available on arm64 as of March 2021

```bash
cat <<EOF> inventory.yaml
groups:
  - name: eksd
    targets:      
EOF
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "      - $i" >> inventory.yaml
done
cat <<EOF>> inventory.yaml 
    config:
      transport: ssh     
EOF
cat inventory.yaml
cp inventory.yaml ~/.puppetlabs/bolt
```

```bash
cat <<EOF> eks.sh
#!/bin/bash
sudo apt update -y
sudo snap remove lxd --purge
sudo snap install eks --channel=latest/edge --classic
sudo eks start
sudo eks status
EOF
chmod 755 eks.sh
```

```bash
bolt script run ./eks.sh --user ubuntu --targets all --no-host-key-check
bolt command run "sudo eks status" --user ubuntu --targets all --no-host-key-check
```

### Checking bolt
```
bolt inventory show --targets <TARGET LIST> --detail
```