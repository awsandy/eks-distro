uname -a | grep aarch64 > /dev/null
if [ $? -ne 0 ];then
    echo "not arm64 architecture exiting ..."
    exit
fi
date
snap install snapcraft --classic
git clone https://github.com/canonical/eks-snap.git
cd eks-snap 
FILE=eks_v1.18.9_arm64.snap
if [ ! -f "$FILE" ]; then
    time snapcraft --use-lxd
fi
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
echo "copy to $i"
scp eks_v1.18.9_arm64.snap ubuntu@$i:eks_v1.18.9_arm64.snap
done
lxc delete snapcraft-eks
cd ~/eks-distro
date
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "setting up EKS Distro on $i"
ssh ubuntu@$i "sudo apt-get upgrade -qq" 2> /dev/null
ssh ubuntu@$i "sudo snap remove lxd --purge" 2> /dev/null
ssh ubuntu@$i "sudo snap install eks_v1.18.9_arm64.snap --classic --dangerous" 2> /dev/null
ssh ubuntu@$i "sudo eks start" 2> /dev/null
echo "EKS Distro completed on $i"
date
done


echo "fix apparmor bug"
find /var/lib/snapd/apparmor/profiles/snap.lxd.* -type f -exec sed -i 's|/usr/sbin/aa-exec ux,|/usr/bin/aa-exec ux,|g' {} \; > /dev/null
apparmor_parser -r /var/lib/snapd/apparmor/profiles/* -v
lxc list
# fix
sleep 30
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
ssh ubuntu@$i "sudo eks status" | grep "eks is not running" 2> /dev/null
if [ $? -eq 0 ];then
    echo "ERROR: eks not running on $i sleep and try again..."
    sleep 60  
    ssh ubuntu@$i "sudo eks status" | grep "eks is not running" 2> /dev/null
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

