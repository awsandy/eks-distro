for i in `lxc list | grep eth0 | awk '{print $6}'`;do
lxc delete snapcraft-eks
echo "copy to $i"
scp eks-snap/eks_v1.18.9_arm64.snap ubuntu@$i:eks_v1.18.9_arm64.snap 2> /dev/null
done