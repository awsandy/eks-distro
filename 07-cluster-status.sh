for i in `lxc list | grep eth0 | awk '{print $6}'`;do
ssh ubuntu@$i "sudo eks status" | grep "eks is not running" 2> /dev/null
if [ $? -eq 0 ];then
    echo "ERROR: eks not running on $i sleep and try again..."
    sleep 60  
    ssh ubuntu@$i "sudo eks status" | grep "eks is not running" 2> /dev/null
else
 echo "EKS ok on $i"
fi
done