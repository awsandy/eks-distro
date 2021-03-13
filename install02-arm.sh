uname -a | grep aarch64 > /dev/null
if [ $? -ne 0 ];then
    echo "not arm64 architecture exiting ..."
    exit
fi


for i in `lxc list | grep eth0 | awk '{print $6}'`;do
lxc delete snapcraft-eks
echo "copy to $i"
scp eks_v1.18.9_arm64.snap ubuntu@$i:eks_v1.18.9_arm64.snap 2> /dev/null
done
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
#
date
node1=`lxc list | grep eth0 | grep eksd1 | awk '{print $6}'`
for i in `lxc list | grep eth0 | grep -v eksd1 | awk '{print $6}'`;do
echo "getting join command from $node1"
jcmd=$(ssh ubuntu@$node1 "sudo eks add-node" | grep eks | head -1)
echo "joining $i to eksd1 $node1"
ssh ubuntu@$i "sudo $jcmd" 2> /dev/null
done
date
#
mkdir -p ~/.kube
touch ~/.kube/config
ssh ubuntu@eksd1 "sudo eks config" > ~/.kube/config
chmod 600 ~/.kube/config
#
kubectl get nodes
kubectl cluster-info
kubectl get all -A
date

