#!/bin/bash
clear
echo ##########GET request for time#############
wget --method GET --no-check-certificate -q --header 'authorization: Basic YWRtaW46U2VjdXJpdHkuNHU='  https://10.130.129.211/api/system/v1/time -O tmpfile
#echo "$(cat tmpfile)"

grep -o [0-9].*Z  tmpfile > tmpsfile2
#echo "$(cat tmpsfile2)"
ANS=$(grep -E -o [0-9]{4}-\(0[1-9]\|1[0-2]\)-\(0[1-9]\|1[0-9]\|2[0-9]\|3[0-1]\)T\(0[1-9]\|1[0-9]\|2[0-3]\):\([0-5][0-9]\):\([0-5][0-9]\).[0-9]{3}Z tmpsfile2)
if [ $? -eq 0 ]
then
	echo "Correct UTC format: $ANS"
fi
rm tmp* # file* 
echo "##########GET request for time#############"
