date
echo "fix apparmor bug"
find /var/lib/snapd/apparmor/profiles/snap.lxd.* -type f -exec sed -i 's|/usr/sbin/aa-exec ux,|/usr/bin/aa-exec ux,|g' {} \; > /dev/null
apparmor_parser -r /var/lib/snapd/apparmor/profiles/* -v
lxc list
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "setting up EKS Distro on $i"
ssh ubuntu@$i "sudo snap install eks_v1.18.9_arm64.snap --classic --dangerous" 2> /dev/null
echo "EKS Distro completed on $i"
date
done