#!/bin/bash

clear
declare -i RESULT=0
declare -i RESULT_FAIL=0
declare -i CPT=0
FAIL=""
ALL_FAIL=1

TEST_ARRAY=("machinectl | head -2" \
)

TEST_APP=("journalctl -M pxmc | ")


#test if pxmc container is alive
PXMC_ALIVE=$(ssh root@10.106.94.104 "machinectl | head -2")
ANS=$(echo $PXMC_ALIVE | grep "pxmc container")
#ANS=$(echo $PXMC_ALIVE | grep "toto container")
if [ $? -eq 0 ]
then
	echo "pxmc container is alive ... ok :)"
	RESULT=$((RESULT+1))
#	echo "${RESULT}"
else
	echo "pxmc container is NOT alive ... ok :("
	FAIL+="test if container is alive "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))
echo ""

#test if PXMCApplication is runing
ssh root@10.106.94.104 "journalctl -M pxmc | grep -i \"PXMCApplication.*failed*\""
#ssh root@10.106.94.104 "journalctl -M pxmc | grep -i -v \"PXMCApplication.*failed*\""
if [ $? -eq 0 ]
then
	echo "PXMCApplication ERROR ... :("
	FAIL+="PXMCApplication "
	RESULT_FAIL=$((RESULT_FAIL+1))
else
	echo "PXMCApplication is alive ... ok :)"
	RESULT=$((RESULT+1))
#	echo "${RESULT}"
fi	
CPT=$((CPT+1))
echo ""

#test if postgresql is runing
ssh root@10.106.94.104 "journalctl -M pxmc | grep -i \"postgresql.*failed*\""
#ssh root@10.106.94.104 "journalctl -M pxmc | grep -i -v \"postgresql.*failed*\""
if [ $? -eq 0 ]
then
	echo "postgresql ERROR ... :("
	FAIL+="postgresql "
	RESULT_FAIL=$((RESULT_FAIL+1))
else
	echo "postgresql is alive ... ok :)"
	RESULT=$((RESULT+1))
#	echo "${RESULT}"
fi	
CPT=$((CPT+1))
echo ""

#read cpu
CPU=$(ssh root@10.106.94.104 "systemd-cgtop -M pxmc")
#CPU=$(echo ${CPU} | awk '{print $9}')
CPU=$(echo ${CPU} | awk '{print $3}')
if [ $? -ne 0 ] || [ -z "${CPU}" ]
then
	echo "ERROR to read CPU value"
	FAIL+="CPU "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
if [ "${CPU}" = "-" ]
then
	CPU="less than 1%"
fi
echo "CPU=${CPU}"
RESULT=$((RESULT+1))
#echo "${RESULT}"
CPT=$((CPT+1))
echo ""

#read memory
MEM=$(ssh root@10.106.94.104 "systemd-cgtop -M pxmc")
#MEM=$(ssh root@10.106.94.104 "systemd-cgtop -M pxi]wssmc")
if [ $? -ne 0 ] || [ -z "${MEM}" ]
then
	echo "ERROR to read memory value"
	FAIL+="memory "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
#echo "MEM=${MEM}"
MEM=$(echo ${MEM} | awk '{print $4}')
echo "MEM=${MEM}"
RESULT=$((RESULT+1))
#echo "${RESULT}"
CPT=$((CPT+1))
echo ""

#Test if UI is reachable
wget -q https://10.106.94.104/pxmc --no-check-certificate
#wget -q https://10.106.94.104/pxmc --no-checrtificate
if [ $? -eq 0 ]
then
	echo "UI is reacheable ... ok :)"
	RESULT=$((RESULT+1))
#	echo "${RESULT}"
else
	echo "UI is not reachable ERROR ... :("
	FAIL+="UI "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))
echo ""

#Test if syslog us runing in the container
SYS=$(ssh root@10.106.94.104 "systemctl status systemd-nspawn@pxmc.service | grep syslog")
#SYS=$(ssh root@10.106.94.104 "systemctl status systemd-nspawn@pxmc.service | grep toto")
if [ $? -eq 0 ]
then
	echo "syslog is running ... ok :)"
	RESULT=$((RESULT+1))
	#echo "${RESULT}"
else
	echo "Syslog is not running ERROR ... :("
	FAIL+="syslog "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
echo ""
CPT=$((CPT+1))
#Test if we can read database
SYS=$(ssh root@10.106.94.104 "ls /var/containers/data/pxmc")
#SYS=$(ssh root@10.106.94.104 "ls /var/containers/data/pxmcdwcdwd")
if [ $? -eq 0 ]
then
	echo "Database ... ok :)"
	RESULT=$((RESULT+1))
	#echo "${RESULT}"
else
	echo "Database issue ERROR ... :("
	FAIL+="Database "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))
echo ""


echo "##########################################################"
#echo "RESULT: ${RESULT}"
#echo "CPT: ${CPT}"
if [ ${RESULT} -ne ${CPT} ]
then
	RES=$(echo "scale=2; ${RESULT_FAIL}/${CPT}*100" | bc -l)
	echo "The following test failed: ${FAIL}"
	echo "${RES} % failed"
else
	echo "All tests passed :)"
fi

#clean up
rm pxmc*
