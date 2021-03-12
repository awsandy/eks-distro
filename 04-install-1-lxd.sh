cd ~/eks-distro
date
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "setting up EKS Distro on $i"
ssh ubuntu@$i "sudo apt-get upgrade -qq" 2> /dev/null
ssh ubuntu@$i "sudo snap remove lxd --purge" 2> /dev/null
echo "EKS Distro completed on $i"
date
done