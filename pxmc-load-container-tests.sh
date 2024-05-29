#!/bin/sh

clear
RESULT=0
RESULT_FAIL=0
CPT=0
FAIL=""
PATH_SMP_LOG="/var/log/smp/"
FILE_TMP="/var/log/smp/tmp_file_load_container"
A_PATH="/var/containers/data/pxmc/"
BUFFER_LOG=""
IP=""
#########################################
###########Program starts here###########
#########################################

echo "Enter IP of the DA"
read IP
if [ -z ${IP} ]
then
	#current IP of my local machine
	IP=192.168.2.212
else
	ping -c 3 ${IP}
	if [ $? -ne 0 ]
	then
		printf "IP: $IP is not reachable \033[91m FAILED\n\033[0m"
		exit
	fi
fi
PXMC_info ()
{

SERIAL_NUMBER=$(ssh root@${IP}  "sys-prod | head -3 | tail -1 | cut -d "=" -f 2")
HARDWARE=$(ssh root@${IP} "sys-prod | grep -o DA305[0-9]")

if [ ! -z "${SERIAL_NUMBER}" ] && [ ! -z "${HARDWARE}" ]
then
	echo "Serial Number: ${SERIAL_NUMBER} :)"
	echo "Hardware: ${HARDWARE} :)"
	BUFFER_LOG="${BUFFER_LOG} \nPXMC_info test PASSED"
	printf "PXMC_info test \033[92m PASSED\n\033[0m"
	RESULT=$((RESULT+1))
	#	echo "${RESULT}"
else
	BUFFER_LOG="${BUFFER_LOG} \nERROR PXMC_info  ... :("
	BUFFER_LOG="${BUFFER_LOG} \nPXMC_info test FAILED"
	printf "PXMC_info test: ERROR Serial or Hardware number is EMPTY \033[91m FAILED\n\033[0m"
	FAIL="${FAIL} PXMC_info"
	RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))
echo ""
}

BUFFER_LOG=$(date)
BUFFER_LOG="${BUFFER_LOG} \n#######################"
#test if signature is valid
check_signature ()
{
	BUFFER_LOG="${BUFFER_LOG} \ntest if signature is valid"

	PXMC_SIGNATURE_1=$(ssh root@${IP} "tail -5 /var/log/smp/System/00000000.log | grep -e \"Signature validation OK (SmpDevRootCA1) for: pxmc-container\" | wc -l")

	PXMC_SIGNATURE_2=$(ssh root@${IP} "dmesg | grep -e \"Signature validation OK.*for: pxmc-container.squashfs\"")
	PXMC_SIGNATURE_2=$?

	PXMC_SIGNATURE_3=$(ssh root@${IP} "dmesg | grep -e \"Signature verification succeeded.*pxmc-container\"")
	PXMC_SIGNATURE_3=$?

	if [ "${PXMC_SIGNATURE_1}" -eq 2 ] && [ "${PXMC_SIGNATURE_2}" -eq  0 ] && [ "${PXMC_SIGNATURE_3}" -eq  0 ]
	then
		echo "Signature validation OK ... ok :)"
		BUFFER_LOG="${BUFFER_LOG} \nSignature validation OK PASSED"
		printf "Signature validation OK\033[92m PASSED\n\033[0m"
		RESULT=$((RESULT+1))
		#	echo "${RESULT}"
	else
		echo "ERROR Signature... :("
		BUFFER_LOG="${BUFFER_LOG} \npxmc containers FAILED"
		printf "Test ERROR Signature\033[91m FAILED\n\033[0m"
		FAIL="${FAIL} \ntest if signature is valid "
		RESULT_FAIL=$((RESULT_FAIL+1))
	fi
	CPT=$((CPT+1))
	echo ""
}

BUFFER_LOG="${BUFFER_LOG} \n#######################"

#Test if UI is reachable
UI_reacheable ()
{
ssh root@${IP} "wget  ${IP}/pxmc/on-boarding --no-check-certificate -o ${FILE_TMP}"
ssh root@${IP} "cat ${FILE_TMP} | grep -o \"100%\""
if [ $? -eq 0 ]
then
	echo "UI is reacheable ... ok :)"
	BUFFER_LOG="${BUFFER_LOG} \nUI test PASSED"
	printf "UI test \033[92m PASSED\n\033[0m"
	RESULT=$((RESULT+1))
	#	echo "${RESULT}"
else
	cat ${FILE_TMP} | grep "Bad Gateway"
	if [ "$?" -eq 0 ]
	then
		BUFFER_LOG="${BUFFER_LOG} \nERROR UI BAD Gateway  ... :("
		BUFFER_LOG="${BUFFER_LOG} \nUI test FAILED"
		printf "UI test: ERROR UI BAD Gateway \033[91m FAILED\n\033[0m"
		FAIL="${FAIL} UI "
		RESULT_FAIL=$((RESULT_FAIL+1))
	fi
fi
CPT=$((CPT+1))
echo ""
}

check_PXMC_tests ()
{
ssh root@${IP} "ls /var/containers/data/pxmc/PXMCApplication/*.zip"
	if [ "$?" -ne 0 ]
	then
		echo "PXMC tests... ok :)"
		BUFFER_LOG="${BUFFER_LOG} \nUI test PASSED"
		printf "PXMC tests... \033[92m PASSED\n\033[0m"
		RESULT=$((RESULT+1))
	#	echo "${RESULT}"
	else
	
		BUFFER_LOG="${BUFFER_LOG} \nERROR PXMC tests...  ... :("
		BUFFER_LOG="${BUFFER_LOG} \nPXMC tests... FAILED"
		printf "UI test: ERROR PXMC tests... \033[91m FAILED\n\033[0m"
		FAIL="${FAIL} PXMC tests "
		RESULT_FAIL=$((RESULT_FAIL+1))
fi
CPT=$((CPT+1))
echo ""
}

compute_result ()
{
	BUFFER_LOG="${BUFFER_LOG} \n##########################################################"
	#echo "RESULT: ${RESULT}"
	#echo "CPT: ${CPT}"
	if [ ${RESULT} -ne ${CPT} ]
	then
		RES=$(echo "scale=2; ${RESULT_FAIL}/${CPT}*100" | bc -l)
		echo "The following test failed: ${FAIL}"
		BUFFER_LOG="${BUFFER_LOG} \nThe following test failed: ${FAIL}"
		BUFFER_LOG="${BUFFER_LOG} \n${RES} % failed"

	elif [ "${CPT}" -eq 0 ]
	then
		echo "Nothing done"
		ssh root@${IP} "echo \"Nothing done\" > /var/log/smp/load-test-file"
		exit
	else
		BUFFER_LOG="${BUFFER_LOG} \nAll tests passed :)"
		BUFFER_LOG="${BUFFER_LOG} \n${RESULT}"
		printf "All test passed \033[92m PASSED\n\033[0m"
	fi

	ssh root@${IP} "echo -e \"${BUFFER_LOG}\" > /var/log/smp/load-test-file"
}

while true
do
	echo "###########Menu: choose your test###################"
	echo "1) Check PXMC automatic test"
	echo "2) Check Signature"
	echo "3) UI reacheable"
	echo "4) PXMC info software/hardware"
	echo "h or H) Help"
	echo "q or Q) Quit"
	echo "####################################################"
	read INPUT
	#clear

	if [ "${INPUT}" = "1" ]
	then
		check_PXMC_tests
		
	elif [ "${INPUT}" = "2" ]
	then
		check_signature
		
	elif [ "${INPUT}" = "3" ]
	then
		UI_reacheable
		
	elif [ "${INPUT}" = "4" ]
	then
		PXMC_info
		
	elif [ "${INPUT}" = "h" ] || [ "${INPUT}" = "H" ]
	then
		help_manuel
		
	elif [ "${INPUT}" = "q" ] || [ "${INPUT}" = "Q" ]
	then
		echo "Quit"
		compute_result
		exit
		
	else
		echo "Wrong input, see help"
		help_manuel	
	fi
done
