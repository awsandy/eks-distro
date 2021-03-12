jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd2 "sudo $jcmd" 2> /dev/null
jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd3 "sudo $jcmd" 2> /dev/null
jcmd=$(ssh ubuntu@eksd1 "sudo eks add-node" | grep eks | head -1)
ssh ubuntu@eksd4 "sudo $jcmd" 2> /dev/null
date
mkdir -p ~/.kube
touch ~/.kube/config
ssh ubuntu@eksd1 "sudo eks config" > ~/.kube/config
chmod 600 ~/.kube/config