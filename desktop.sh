#sudo apt-get install xubuntu-desktop -y
#git clone https://github.com/awsandy/eks-distro.git
apt-get update
#sudo DEBIAN_FRONTEND=noninteractive apt-get install xubuntu-core -qq -y
DEBIAN_FRONTEND=noninteractive apt-get install xfce4  -qq -y
apt-get install firefox xfce4-terminal -y
#sudo apt-get install xubuntu-desktop -y
apt-get install xrdp -y
adduser xrdp ssl-cert  
# edit /etc/xrdp/startwm.sh
# replace /etc/X11/Xsession lines with
# startxfce4
cp startwm.sh /etc/xrdp/startwm.sh
systemctl restart xrdp
ufw allow 3389
echo "set a password for user ubuntu with the command:  passwd ubuntu" 



