#!/bin/bash
#IP=10.106.94.104
IP=10.130.129.211
_IP=10.130.129.215
TIME=2023-01-11T12:13:15Z
_TIME=555-01-11T12:13:15Z
USER=root
declare -i RESULT=0
declare -i CPT=0
declare -i RESULT_FAIL=0
FAIL=""


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
	RESULT=$((RESULT+1))

else
	printf "GET test \033[91m FAILED\n\033[0m"
	FAIL+="GET test "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))

echo "##########POST request for time#############"
echo "This time: $TIME will be sent to the DA with this IP $IP"
wget -q --no-check-certificate  --method POST --timeout=0 --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46U2VjdXJpdHkuNHU=' --body-data '{"Value":"'"${TIME}"'"}' https://$IP/api/system/v1/time

if [ $? -ne 0 ]
then
	printf "wget command \033[91m FAILEd\n\033[0m"
	FAIL+=" wget in POST"
	#if it fails => the below test fails as well
	RESULT_FAIL=$((RESULT_FAIL+2))
else
	RESULT=$((RESULT+1))
	####Check result####
	ANS=$(ssh ${USER}@${IP} "systemctl status smp-fcgi-time | grep -E -o [0-9]{4}-\(0[1-9]\|1[0-2]\).* | tail -1")
	echo "$ANS"

	if [ ${ANS} = ${TIME} ]
	then
		printf "POST test \033[92m PASSED\n\033[0m"
		RESULT=$((RESULT+1))
	else
		printf "POST test \033[91m FAILED\n\033[0m"
		FAIL+="test POST"
		RESULT_FAIL=$((RESULT_FAIL+1))
	fi
fi
CPT=$((CPT+2))

echo "RESULT: ${RESULT}"
echo "CPT: ${CPT}"

if [ ${RESULT} -ne ${CPT} ]
then
	RES=$(echo "scale=2; ${RESULT_FAIL}/${CPT}*100" | bc -l)
	echo "The following test failed: ${FAIL}"
	echo "The following test failed: ${FAIL}" >> file.log
	echo "${RES} % failed" >> file.log
	echo "${RES} % failed"
else
	echo "All tests passed :)" >> file.log
	printf "All test passed \033[92m PASSED\n\033[0m"
fi
rm tmp* time* file* 
