#!/bin/bash

clear

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
fi
echo ""

#test if PXMCApplication is runing
ssh root@10.106.94.104 "journalctl -M pxmc | grep -i \"PXMCApplication.*failed*\""
if [ $? -eq 0 ]
then
	echo "PXMCApplication ERROR ... :("
else
	echo "PXMCApplication is alive ... ok :)"
fi	
echo ""

#test if postgresql is runing
ssh root@10.106.94.104 "journalctl -M pxmc | grep -i \"postgresql.*failed*\""
if [ $? -eq 0 ]
then
	echo "postgresql ERROR ... :("
else
	echo "postgresql is alive ... ok :)"
fi	
echo ""
echo ""

#read cpu
CPU=$(ssh root@10.106.94.104 "systemd-cgtop -M pxmc")
CPU=$(echo ${CPU} | awk '{print $3}')
if [ "${CPU}" = "-" ]
then
	CPU="less than 1%"
fi
echo "CPU=${CPU}"

echo ""
#read memory
MEM=$(ssh root@10.106.94.104 "systemd-cgtop -M pxmc")
#echo "MEM=${MEM}"
MEM=$(echo ${MEM} | awk '{print $4}')
echo "MEM=${MEM}"
