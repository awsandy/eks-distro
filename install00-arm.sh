echo "just for Raspberry pi 4"
uname -a | grep aarch64 > /dev/null
if [ $? -ne 0 ];then
    echo "not arm64 architecture exiting ..."
    exit
fi

FILE=/boot/firmware/cmdline.txt
if [  -f "$FILE" ]; then
    sed -i 's/fixrtc/fixrtc cgroup_enable=memory cgroup_memory=1/g' $FILE
fi
echo "now reboot"