date
lxc ls
# no arm bolt just yet for arm64
# ssh to ubuntu@ip.of.lxd
j=1
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "$i eksd$j" >> /etc/hosts
j=`expr $j + 1` 
done


for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "setting up EKS Distro on $i"
ssh ubuntu@$i "sudo apt-get upgrade -qq" 2> /dev/null
ssh ubuntu@$i "sudo snap remove lxd --purge" 2> /dev/null
ssh ubuntu@$i "sudo snap install eks --channel=latest/edge --classic" 2> /dev/null
ssh ubuntu@$i "sudo eks start" 2> /dev/null
echo "EKS Distro completed on $i"
date
done
date
echo "fix apparmor bug"
find /var/lib/snapd/apparmor/profiles/snap.lxd.* -type f -exec sed -i 's|/usr/sbin/aa-exec ux,|/usr/bin/aa-exec ux,|g' {} \; > /dev/null
apparmor_parser -r /var/lib/snapd/apparmor/profiles/* -v
lxc list
# fix
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
ssh ubuntu@$i "sudo eks status" | grep "eks is not running" 2> /dev/null
if [ $? -eq 0 ];then
    echo "ERROR: eks not running on $i exiting..."
    exit 
fi
done

jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd2 "sudo $jcmd" 2> /dev/null
jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd3 "sudo $jcmd" 2> /dev/null
jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd4 "sudo $jcmd" 2> /dev/null
date
mkdir -p ~/.kube
touch ~/.kube/config
ssh ubuntu@eksd1 "sudo eks config" > ~/.kube/config
chmod 600 ~/.kube/config
kubectl get nodes
kubectl cluster-info
kubectl get all -A
date












