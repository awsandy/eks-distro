#snap install amazon-ssm-agent --classic
date
apt update -y && apt upgrade -y
apt-get upgrade -qq
snap install helm --classic
snap install kubectl --classic
snap install jq --classic
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
cat <<EOF> ~/.ssh/config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
lxc profile create microk8s
wget https://raw.githubusercontent.com/ubuntu/microk8s/master/tests/lxc/microk8s.profile -O microk8s.profile
cat  microk8s.profile | lxc profile edit microk8s
for i in {1..4}; do lxc launch -p default -p microk8s ubuntu:20.04 eksd$i; done
sleep 8
lxc ls
date







