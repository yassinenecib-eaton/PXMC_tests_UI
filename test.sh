#!/bin/bash

clear
declare -i RESULT=0
FAIL=""

TEST_ARRAY=("machinectl | head -2" \
)

TEST_APP=("journalctl -M pxmc | ")


#test if pxmc container is alive
ssh root@10.106.94.104 "machinectl | head -2"
PXMC_ALIVE=$(ssh root@10.106.94.104 "machinectl | head -2")
ANS=$(echo $PXMC_ALIVE | grep "pxmc container")
if [ $? -eq 0 ]
then
	echo "pxmc container is alive ... ok :)"
	RESULT=$((RESULT+1))
#	echo "${RESULT}"
else
	FAIL="test if container is alive "
fi
echo ""

#test if PXMCApplication is runing
ssh root@10.106.94.104 "journalctl -M pxmc | grep -i \"PXMCApplication.*failed*\""
if [ $? -eq 0 ]
then
	echo "PXMCApplication ERROR ... :("
else
	echo "PXMCApplication is alive ... ok :)"
	RESULT=$((RESULT+1))
#	echo "${RESULT}"
fi	
echo ""

#test if postgresql is runing
ssh root@10.106.94.104 "journalctl -M pxmc | grep -i \"postgresql.*failed*\""
if [ $? -eq 0 ]
then
	echo "postgresql ERROR ... :("
else
	echo "postgresql is alive ... ok :)"
	RESULT=$((RESULT+1))
#	echo "${RESULT}"
fi	
echo ""

#read cpu
CPU=$(ssh root@10.106.94.104 "systemd-cgtop -M pxmc")
CPU=$(echo ${CPU} | awk '{print $3}')
if [ $? -ne 0 ]
then
	echo "ERROR to read CPU value"
fi
if [ "${CPU}" = "-" ]
then
	CPU="less than 1%"
fi
echo "CPU=${CPU}"
RESULT=$((RESULT+1))
#echo "${RESULT}"

echo ""
#read memory
MEM=$(ssh root@10.106.94.104 "systemd-cgtop -M pxmc")
if [ $? -ne 0 ]
then
	echo "ERROR to read memory value"
fi
#echo "MEM=${MEM}"
MEM=$(echo ${MEM} | awk '{print $4}')
echo "MEM=${MEM}"
RESULT=$((RESULT+1))
#echo "${RESULT}"
echo ""

#Test if UI is reachable
wget -q https://10.106.94.104/pxmc --no-check-certificate
if [ $? -eq 0 ]
then
	echo "UI is reacheable ... ok :)"
	RESULT=$((RESULT+1))
#	echo "${RESULT}"
else
	echo "UI is not reachable ERROR ... :("
fi
echo ""

#Test if syslog us runing in the container
SYS=$(ssh root@10.106.94.104 "systemctl status systemd-nspawn@pxmc.service | grep syslog")
if [ $? -eq 0 ]
then
	echo "syslog is running ... ok :)"
	RESULT=$((RESULT+1))
	#echo "${RESULT}"
else
	echo "Syslog is not running ERROR ... :("
fi
echo ""
echo "##########################################################"
if [ ${RESULT} -ne 7 ]
then
	RES=$(echo "scale=1; ${RESULT}/7" | bc -l)
	RES=$(echo "scale=1; ${RES}*100" | bc -l)
	echo "Test ${FAIL} failed, ${RES} % passed"
else
	echo "All tests passed :)"
fi

#clean up
rm pxmc*
