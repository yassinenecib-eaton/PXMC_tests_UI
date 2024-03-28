#!/bin/bash
IP=10.106.94.104
TIME=2023-01-11T12:13:15Z
USER=root
clear
echo "##########GET request for time#############"
wget --method  GET --no-check-certificate -q --header 'authorization: Basic YWRtaW46U2VjdXJpdHkuNHU='  https://${IP}/api/system/v1/time -O tmpfile
#echo "$(cat tmpfile)"

grep -o [0-9].*Z  tmpfile > tmpsfile2
#echo "$(cat tmpsfile2)"
ANS=$(grep -E -o [0-9]{4}-\(0[1-9]\|1[0-2]\)-\(0[1-9]\|1[0-9]\|2[0-9]\|3[0-1]\)T\(0[1-9]\|1[0-9]\|2[0-3]\):\([0-5][0-9]\):\([0-5][0-9]\).[0-9]{3}Z tmpsfile2)
if [ $? -eq 0 ]
then
	echo "Correct UTC format: $ANS"
	printf "GET test \033[92m PASSED\n\033[0m"
else
	printf "GET test \033[91m FAILED\n\033[0m"
	exit
fi
echo "##########POST request for time#############"
echo "This time: $TIME will be sent to the DA with this IP $IP"
wget -q --no-check-certificate  --method POST --timeout=0 --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46U2VjdXJpdHkuNHU=' --body-data '{"Value":"'"${TIME}"'"}' https://$IP/api/system/v1/time

if [ $? -ne 0 ]
then
	printf "wget command \033[91m FAILEd\n\033[0m"
	exit
else
	printf "wget command \033[92m PASSED\n\033[0m"
fi

####Check result####
ANS=$(ssh ${USER}@${IP} "systemctl status smp-fcgi-time | grep -E -o [0-9]{4}-\(0[1-9]\|1[0-2]\).* | tail -1")
echo "$ANS"

if [ ${ANS} = ${TIME} ]
then
	printf "POST test passed \033[92m PASSED\n\033[0m"
else
	printf "POST test passed \033[91m FAILED\n\033[0m"
fi
rm tmp* time* # file* 
