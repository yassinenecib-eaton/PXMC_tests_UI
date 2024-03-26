#!/bin/bash

clear
declare -i RESULT=0
declare -i RESULT_FAIL=0
declare -i CPT=0
FAIL=""

TEST_ARRAY=("machinectl | head -2" \
	)

TEST_APP=("journalctl -M pxmc | ")

#if file.log "file.log" does not exist we create it, unless we delete it
[ ! -e ./file.log ] && touch ./file.log || rm file.log

echo $(date) >> file.log
echo "#######################" >> file.log
#test if pxmc container is alive
echo "test if pxmc container is alive" >> file.log
ssh root@10.106.94.104 "machinectl | head -2" >> file.log
PXMC_ALIVE=$(ssh root@10.106.94.104 "machinectl | head -2")
ANS=$(echo $PXMC_ALIVE | grep "pxmc container")
#ANS=$(echo $PXMC_ALIVE | grep "toto container")
if [ $? -eq 0 ]
then
	echo "pxmc container is alive ... ok :)"
	echo "pxmc container PASSED" >> file.log
	printf "Test pxmc container\033[92m PASSED\n\033[0m"
	RESULT=$((RESULT+1))
	#	echo "${RESULT}"
else
	echo "pxmc container is NOT alive ... ok :("
	echo "pxmc container FAILED" >> file.log
	printf "Test pxmc container\033[91m FAILED\n\033[0m"
	FAIL+="test if container is alive "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))
echo ""
echo "#######################" >> file.log
echo "test if PXMCApplication is runing" >> file.log
#test if PXMCApplication is runing
ssh root@10.106.94.104 "journalctl -M pxmc | grep -i \"PXMCApplication.*failed*\""
#ssh root@10.106.94.104 "journalctl -M pxmc | grep -i -v \"PXMCApplication.*failed*\""
if [ $? -eq 0 ]
then
	echo "PXMCApplication ERROR ... :("
	echo "test PXMCApplication FAILED" >> file.log
	printf "Test PXMCApplication\033[91m FAILED\n\033[0m"
	FAIL+="PXMCApplication "
	RESULT_FAIL=$((RESULT_FAIL+1))
else
	echo "PXMCApplication is alive ... ok :)"
	echo "test PXMCApplication PASSED" >> file.log
	printf "Test PXMCApplication\033[92m PASSED\n\033[0m"
	RESULT=$((RESULT+1))
	#	echo "${RESULT}"
fi	
CPT=$((CPT+1))
echo ""

echo "#######################" >> file.log
echo "test if postgresql is runing" >> file.log
#test if postgresql is runing
ssh root@10.106.94.104 "journalctl -M pxmc | grep -i \"postgresql.*failed*\""
#ssh root@10.106.94.104 "journalctl -M pxmc | grep -i -v \"postgresql.*failed*\""
if [ $? -eq 0 ]
then
	echo "postgresql ERROR ... :("
	echo "postgresql FAILED" >> file.log
	printf "postgresql \033[91m FAILED\n\033[0m"
	FAIL+="postgresql "
	RESULT_FAIL=$((RESULT_FAIL+1))
else
	echo "postgresql is alive ... ok :)"
	echo "postgresql PASSED" >> file.log
	printf "postgresql \033[92m PASSED\n\033[0m"
	RESULT=$((RESULT+1))
	#	echo "${RESULT}"
fi	
CPT=$((CPT+1))
echo ""

echo "#######################" >> file.log
echo "test read cpu" >> file.log
#read cpu
ssh root@10.106.94.104 "systemd-cgtop -M pxmc" >> file.log
CPU=$(ssh root@10.106.94.104 "systemd-cgtop -M pxmc")
#CPU=$(echo ${CPU} | awk '{print $9}')
CPU=$(echo ${CPU} | awk '{print $3}')
if [ $? -ne 0 ] || [ -z "${CPU}" ]
then
	echo "ERROR to read CPU value"
	echo "test read cpu FAILED" >> file.log
	printf "test read cpu \033[91m FAILED\n\033[0m"
	FAIL+="CPU "
	RESULT_FAIL=$((RESULT_FAIL+1))

elif [ "${CPU}" = "-" ]
then
	CPU="less than 1%"
	echo "test read cpu PASSED" >> file.log
	printf "test read cpu \033[92m PASSED\n\033[0m"
else
	echo "test read cpu PASSED" >> file.log
	printf "test read cpu \033[92m PASSED\n\033[0m"
fi
echo "CPU=${CPU}"
RESULT=$((RESULT+1))
#echo "${RESULT}"
CPT=$((CPT+1))
echo ""

echo "#######################" >> file.log
echo "test read memory" >> file.log

#read memory
ssh root@10.106.94.104 "systemd-cgtop -M pxmc" >> file.log
MEM=$(ssh root@10.106.94.104 "systemd-cgtop -M pxmc")
#MEM=$(ssh root@10.106.94.104 "systemd-cgtop -M pxi]wssmc")
if [ $? -ne 0 ] || [ -z "${MEM}" ]
then
	echo "ERROR to read memory value"
	echo "test read memory FAILED" >> file.log
	printf "test read memory \033[91m FAILED\n\033[0m"
	FAIL+="memory "
	RESULT_FAIL=$((RESULT_FAIL+1))
else
	MEM=$(echo ${MEM} | awk '{print $4}')
	echo "MEM=${MEM}"
	echo "test read memory PASSED" >> file.log
	printf "test read memory \033[92m PASSED\n\033[0m"
fi
#echo "MEM=${MEM}"
RESULT=$((RESULT+1))
#echo "${RESULT}"
CPT=$((CPT+1))
echo ""

echo "#######################" >> file.log
echo "Test if UI is reachable" >> file.log
#Test if UI is reachable
wget  https://10.106.94.104/pxmc -q -O tmpfile.log --no-check-certificate
#wget  https://10.14.104/pxmc -q -O tmpfile.log --no-check-certificate
if [ $? -eq 0 ]
then
	cat tmpfile.log >> file.log
	rm tmpfile.log
	echo "UI is reacheable ... ok :)"
	echo "UI test PASSED" >> file.log
	printf "UI test \033[92m PASSED\n\033[0m"
	RESULT=$((RESULT+1))
	#	echo "${RESULT}"
else
	cat tmpfile.log >> file.log
	rm tmpfile.log
	echo "UI is not reachable ERROR ... :("
	echo "UI test FAILED" >> file.log
	printf "UI test \033[91m FAILED\n\033[0m"
	FAIL+="UI "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))
echo ""

echo "#######################" >> file.log
echo "Test if syslog us runing in the container" >> file.log
#Test if syslog us runing in the container
ssh root@10.106.94.104 "systemctl status systemd-nspawn@pxmc.service | grep syslog" >> file.log
SYS=$(ssh root@10.106.94.104 "systemctl status systemd-nspawn@pxmc.service | grep syslog")
#SYS=$(ssh root@10.106.94.104 "systemctl status systemd-nspawn@pxmc.service | grep toto")
if [ $? -eq 0 ]
then
	echo "syslog is running ... ok :)"
	echo "Test syslog PASSED" >> file.log
	printf "Test syslog \033[92m PASSED\n\033[0m"
	RESULT=$((RESULT+1))
	#echo "${RESULT}"
else
	echo "Syslog FAILED ... :("
	echo "Test syslog FAILED" >> file.log
	printf "Test syslog \033[91m FAILED\n\033[0m"
	FAIL+="syslog "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
echo ""

echo "#######################" >> file.log
echo "Test if we can read database" >> file.log
CPT=$((CPT+1))
#Test if we can read database
ssh root@10.106.94.104 "ls /var/containers/data/pxmc" >> file.log
AND=$(ssh root@10.106.94.104 "ls /var/containers/data/pxmc")
#$(ssh root@10.106.94.104 "ls /var/containers/data/pxmcdwcdwd")
if [ $? -eq 0 ]
then
	echo "Database ... ok :)"
	echo "Test database PASSED" >> file.log
	printf "Test database \033[92m PASSED\n\033[0m"
	RESULT=$((RESULT+1))
	#echo "${RESULT}"
else
	echo "Database issue ERROR ... :("
	echo "Test database FAILED" >> file.log
	printf "Test database \033[91m FAILED\n\033[0m"
	RESULT=$((RESULT+1))
	FAIL+="Database "
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))
echo ""


echo "##########################################################"
echo "##########################################################" >> file.log
#echo "RESULT: ${RESULT}"
#echo "CPT: ${CPT}"
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

