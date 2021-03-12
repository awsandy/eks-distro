date
node1=`lxc list | grep eth0 | grep eksd1 | awk '{print $6}'`
for i in `lxc list | grep eth0 | grep -v eksd1 | awk '{print $6}'`;do
echo "getting join command from $node1"
jcmd=$(ssh ubuntu@$node1 "sudo eks add-node" | grep eks | head -1)
echo "joining $i to eksd1 $node1"
ssh ubuntu@$i "sudo $jcmd" 2> /dev/null
done
date
mkdir -p ~/.kube
touch ~/.kube/config
ssh ubuntu@eksd1 "sudo eks config" > ~/.kube/config
chmod 600 ~/.kube/config