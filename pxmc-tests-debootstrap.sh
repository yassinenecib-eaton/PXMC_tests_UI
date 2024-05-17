#!/bin/sh

clear
#pxmc-debootstrap check if how many time it read "PASSED" and compare it with RESULT
#If there is a diffence, rescue app sequence is loading
RESULT=1
RESULT_FAIL=0
CPT=0
FAIL=""
BUFFER_LOG=""
INPUT=""
IP="192.168.2.212"
FILE_LOG="file.log"
BUFFER_LOG=$(date)
container_alive ()
{
	BUFFER_LOG="${BUFFER_LOG} \n#######################"
	#test if pxmc containers is alive
	BUFFER_LOG="${BUFFER_LOG} \ntest if pxmc containers is alive"

	echo "pxmc containers is NOT alive ... ok :("
	BUFFER_LOG="${BUFFER_LOG} \npxmc containers FAILED"
	printf "Test pxmc containers\033[91m FAILED\n\033[0m"
	FAIL="${FAIL} \n-containers"
	RESULT_FAIL=$((RESULT_FAIL+1))

	CPT=$((CPT+1))
	echo ""
}

directory_structure ()
{
	BUFFER_LOG="${BUFFER_LOG} \n#######################"
	echo "test the structure directory"
	BUFFER_LOG="${BUFFER_LOG} \ntest the structure directory"

	echo "Structure directory ERROR ... :("
	BUFFER_LOG="${BUFFER_LOG} \ntest Structure directory FAILED"
	printf "Test Structure directory\033[91m FAILED\n\033[0m"
	FAIL="${FAIL}\n-Structure directory "
	RESULT_FAIL=$((RESULT_FAIL+1))
	
	CPT=$((CPT+1))
	echo ""
}

database ()
{
	BUFFER_LOG="${BUFFER_LOG} \n#######################"
	BUFFER_LOG="${BUFFER_LOG} \ntest if postgresql is runing"

	echo "postgresql ERROR ... :("
	echo "postgresql FAILED"
	BUFFER_LOG="${BUFFER_LOG} \nTest database FAILED"
	printf "postgresql \033[91m FAILED\n\033[0m"
	FAIL="${FAIL} \n-postgresql"
	RESULT_FAIL=$((RESULT_FAIL+1))

	CPT=$((CPT+1))
	echo ""
}

PXMCApplication ()
{
	BUFFER_LOG="${BUFFER_LOG} \n#######################"
	BUFFER_LOG="${BUFFER_LOG} \ntest if PXMCApplication is runing"
	echo "PXMCApplication ERROR ... :("
	echo "test PXMCApplication FAILED"
	printf "Test PXMCApplication\033[91m FAILED\n\033[0m"
	FAIL="${FAIL} \n-PXMCApplication "
	RESULT_FAIL=$((RESULT_FAIL+1))

	CPT=$((CPT+1))
	echo ""
}

cpu_ressource ()
{
	BUFFER_LOG="${BUFFER_LOG} \n#######################"
	BUFFER_LOG="${BUFFER_LOG} \ntest read cpu"
	echo "ERROR to read CPU value"
	BUFFER_LOG="${BUFFER_LOG} \ntest read cpu FAILED"
	printf "test read cpu \033[91m FAILED\n\033[0m"
	FAIL="${FAIL} \n-CPU"
	RESULT_FAIL=$((RESULT_FAIL+1))

	CPT=$((CPT+1))
	echo ""
}

memory_ram_ressource ()
{
	BUFFER_LOG="${BUFFER_LOG} \n#######################"
	BUFFER_LOG="${BUFFER_LOG} \ntest read memory"

	echo "ERROR to read memory value"
	BUFFER_LOG="${BUFFER_LOG} \ntest read memory FAILED"
	printf "test read memory \033[91m FAILED\n\033[0m"
	FAIL="${FAIL} \n-memory"
	RESULT_FAIL=$((RESULT_FAIL+1))
	
	CPT=$((CPT+1))
	echo ""
}

test_syslog ()
{
	BUFFER_LOG="${BUFFER_LOG} \n#######################"
	BUFFER_LOG="${BUFFER_LOG} \nTest if syslog us runing in the containers"
	
	BUFFER_LOG="${BUFFER_LOG} \nTest syslog FAILED"
	printf "Test syslog \033[91m FAILED\n\033[0m"
	FAIL="${FAIL} \n-syslog"
	RESULT_FAIL=$((RESULT_FAIL+1))

	CPT=$((CPT+1))
	echo ""
}


UI_reacheable()
{
	BUFFER_LOG="${BUFFER_LOG} \nUI is not reachable ERROR ... :("
	BUFFER_LOG="${BUFFER_LOG} \nUI test FAILED"
	printf "UI test \033[91m FAILED\n\033[0m"
	FAIL="${FAIL} \n-UI"
	RESULT_FAIL=$((RESULT_FAIL+1))

	CPT=$((CPT+1))
	echo ""
}

database_folder ()
{
	BUFFER_LOG="${BUFFER_LOG} \n#######################"
	BUFFER_LOG="${BUFFER_LOG} \nTest if we can read database"
	
	echo "Database issue ERROR ... :("
	BUFFER_LOG="${BUFFER_LOG} \nTest database FAILED"
	printf "Test database \033[91m FAILED\n\033[0m"

	FAIL="${FAIL} \n-Database folder"
	RESULT_FAIL=$((RESULT_FAIL+1))

	CPT=$((CPT+1))
	echo ""
}
compute_result ()
{
	if [ "${CPT}" -eq 0 ]
	then
		echo "No tests executed"
		exit
	fi
	BUFFER_LOG="${BUFFER_LOG} \n##########################################################"
	RES=$(echo "scale=2; ${RESULT_FAIL}/${CPT}*100" | bc -l)
	echo "The following test failed: ${FAIL}"
	BUFFER_LOG="${BUFFER_LOG} \nThe following test failed: ${FAIL}"
	BUFFER_LOG="${BUFFER_LOG} \n${RES} % failed"
	BUFFER_LOG="${BUFFER_LOG} \n${RESULT}"
	echo -e "${BUFFER_LOG}"
	echo -e "${BUFFER_LOG}" > ./${FILE_LOG}
	scp ./${FILE_LOG} root@${IP}:/var/log/smp/file.log
	
	if [ "$?" -eq 0 ]
	then
		echo "File file.log copied in the target properly"
		scp root@${IP} "ls -l /var/log/smp/"
	fi
	#echo -e "${BUFFER_LOG}" > ./file.log
}

help_manuel ()
{
	echo "########### Help ###################"
	echo "1) pxmc-container alive"
	echo "2) Directory structure"
	echo "3) Database postgresql"
	echo "4) PXMC Application"
	echo "h or H) Help"
	echo "q or Q) Quit"
}

while true
do
	echo "###########Menu: choose your test###################"
	echo "1) pxmc-container alive"
	echo "2) Directory structure"
	echo "3) Database postgresql"
	echo "4) PXMC Application"
	echo "5) CPU ressource"
	echo "6) RAM memory ressource"
	echo "7) UI reacheable"
	echo "8) Test syslog"
	echo "9) Database Folder exist ?"
	echo "h or H) Help"
	echo "q or Q) Quit"
	echo "####################################################"
	read INPUT
	clear

	if [ "${INPUT}" = "1" ]
	then
		container_alive
		
	elif [ "${INPUT}" = "2" ]
	then
		directory_structure
		
	elif [ "${INPUT}" = "3" ]
	then
		database
		
	elif [ "${INPUT}" = "4" ]
	then
		PXMCApplication
		
	elif [ "${INPUT}" = "5" ]
	then
		cpu_ressource
		
	elif [ "${INPUT}" = "6" ]
	then	
		memory_ram_ressource
		
	elif [ "${INPUT}" = "7" ]
	then	
		UI_reacheable
		
	elif [ "${INPUT}" = "8" ]
	then	
		test_syslog
		
	elif [ "${INPUT}" = "9" ]
	then	
		database_folder
		
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




