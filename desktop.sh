#sudo apt-get install xubuntu-desktop -qq
cd ~/eks-distro
sudo apt-get update

#sudo DEBIAN_FRONTEND=noninteractive apt-get install xubuntu-core -qq -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install xfce4  -qq -y
sudo apt-get install xrdp -qq

sudo adduser xrdp ssl-cert  
# edit /etc/xrdp/startwm.sh
# replace /etc/X11/Xsession lines with
# startxfce4
cp startwm.sh /etc/xrdp/startwm.sh
sudo systemctl restart xrdp
sudo ufw allow 3389


passwd ubuntu << EOF
linuxpassword0321
linuxpassword0321
EOF



