#snap install amazon-ssm-agent --classic
apt update -y
#apt install snapd -y
#snap install lxd
wget https://apt.puppet.com/puppet-tools-release-focal.deb 
dpkg -i puppet-tools-release-focal.deb 
apt-get update -y
apt-get install puppet-bolt -y
snap install helm --classic
snap install kubectl --classic
snap install jq --classic
mkdir -p .kube
touch .kube/config
cat <<EOF | lxd init  --preseed
storage_pools:
- name: default
  driver: dir
  config:
    source: ""
networks:
- name: lxdbr0
  type: bridge
  config:
    ipv4.address: auto
    ipv6.address: none
profiles:
- name: default
  devices:
    root:
      path: /
      pool: default
      type: disk
    eth0:
      nictype: bridged
      parent: lxdbr0
      type: nic
EOF
#lxc network show lxdbr0
#config:
#  ipv4.address: 10.241.112.1/24
#  ipv4.nat: "true"
##lxc storage show default
#lxc profile show default  > lxd-profile-default.yaml
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
chmod 600 ~/.ssh/id*
cat << EOF > default.yaml
config:
  user.user-data: |
    #cloud-config
    ssh_authorized_keys:
      - @@SSHPUB@@
  environment.http_proxy: ""
  user.network_mode: ""
desription: Default LXD profile
devices:
  eth0:
    nictype: bridged
    parent: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    type: disk
name: default
used_by: []
EOF
sed -ri "s'@@SSHPUB@@'$(cat ~/.ssh/id_rsa.pub)'" default.yaml
cat default.yaml | lxc profile edit default
cat <<EOF> .ssh/config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

lxc profile create microk8s
wget https://raw.githubusercontent.com/ubuntu/microk8s/master/tests/lxc/microk8s.profile -O microk8s.profile
cat  microk8s.profile | lxc profile edit microk8s
for i in {1..4}; do lxc launch -p default -p microk8s ubuntu:20.04 eksd$i; done
lxc ls
# no arm bolt just yet for arm64
# ssh to ubuntu@ip.of.lxd



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

lxc exec eksd1 -- sudo eks add-node
# returns a join command - run this on eksd2 eksd3 etc ....
ssh ubuntu@10.169.147.134 "sudo eks join 10.169.147.183:25000/1828a4b96effd7b3820faef6a70713e7"
ssh ubuntu@10.169.147.183 "sudo eks config" > .kube/config
kubectl get nodes
kubectl cluster-info
kubectl get all -A









