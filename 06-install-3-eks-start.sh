cd ~/eks-distro
date
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "Starting EKS on $i"
ssh ubuntu@$i "sudo eks start" 2> /dev/null
echo "EKS started on $i"
date
done