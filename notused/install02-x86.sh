
lxc ls
# no arm bolt just yet for arm64
# ssh to ubuntu@ip.of.lxd
j=1
for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "$i eksd$j" >> /etc/hosts
j=`expr $j + 1` 
done

for i in `lxc list | grep eth0 | awk '{print $6}'`;do
ssh ubuntu@$i "sudo date"
done

for i in `lxc list | grep eth0 | awk '{print $6}'`;do
echo "setting up EKS Distro in $i"
ssh ubuntu@$i "sudo apt -qq update -y"
ssh ubuntu@$i "sudo snap remove lxd --purge"
ssh ubuntu@$i "sudo snap install eks --channel=latest/edge --classic"
ssh ubuntu@$i "sudo eks start"
echo "EKS Distro completed in $i"
done

find /var/lib/snapd/apparmor/profiles/snap.lxd.* -type f -exec sed -i 's|/usr/sbin/aa-exec ux,|/usr/bin/aa-exec ux,|g' {} \;
apparmor_parser -r /var/lib/snapd/apparmor/profiles/* -v
lxc list
# fix


for i in `lxc list | grep eth0 | awk '{print $6}'`;do
ssh ubuntu@$i "sudo eks status"
done

jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd2 "sudo $jcmd"
jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd3 "sudo $jcmd"
jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd4 "sudo $jcmd"
ssh ubuntu@eksd1 "sudo eks config" > .kube/config
kubectl get nodes
kubectl cluster-info
kubectl get all -A




ssh ubuntu@eksd1 "sudo eks add-node"

lxc exec eksd1 -- sudo eks add-node
# returns a join command - run this on eksd2 eksd3 etc ....
ssh ubuntu@10.169.147.134 "sudo eks join 10.169.147.183:25000/1828a4b96effd7b3820faef6a70713e7"
ssh ubuntu@10.169.147.183 "sudo eks config" > .kube/config
kubectl get nodes
kubectl cluster-info
kubectl get all -A




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
cat <<EOF> eks.sh
#!/bin/bash
sudo apt update -y
sudo snap remove lxd --purge
sudo snap install eks --channel=latest/edge --classic
sudo eks start
sudo eks status
EOF
chmod 755 eks.sh
bolt script run ./eks.sh --user ubuntu --targets all --no-host-key-check
bolt command run "sudo eks status" --user ubuntu --targets all --no-host-key-check











