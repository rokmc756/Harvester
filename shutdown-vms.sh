
for i in `seq 1 3`;
do
    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no rancher@192.168.0.19$i "sudo shutdown -h now"
done

ssh root@192.168.0.90 "shutdown -h now"

