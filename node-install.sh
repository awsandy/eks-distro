## ssh ubuntu@ip.of.lxd
# sudo snap remove lxd --purge
#ubuntu@eksd1:~$ sudo snap install eks --channel=latest/edge --classic
#error: snap "eks" is not available on edge for this architecture (arm64) but exists on other
#       architectures (amd64).
snap install snapcraft --classic
git clone https://github.com/canonical/eks-snap.git
cd eks-snap
snapcraft --use-lxd




