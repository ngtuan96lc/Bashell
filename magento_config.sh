# =============================================== #
# Tool : Automation create new domain server	  #
# Author : Nguyen Hoang Tuan - Developer Magento  #
# Office : SmartOSC Joint-Stock Company, Hanoi	  #
# =============================================== #


#========================================
# Include source color
#
# reset color
COLOR_OFF='\033[0m'       # Text Reset

# Regular Colors
BLACK='\033[0;30m'        # Black
RED='\033[0;31m'          # Red
GREEN='\033[0;32m'        # Green
YELLOW='\033[0;33m'       # Yellow
BLUE='\033[0;34m'         # Blue
PURPLE='\033[0;35m'       # Purple
CYAN='\033[0;36m'         # Cyan
WHITE='\033[0;37m'        # White


#========================================
# GLOBAL variables
#
PATH_CONFIG_NGINX="/etc/nginx/sites-available/"
PATH_CONFIG_NGINX_SYMLINK="/etc/nginx/sites-enabled"
PATH_HOSTS="/etc/hosts"


#========================================
# Function validate file name which enter from keyboard
# @param $1 | filename config
#
validateFileName() {
	status=0
	sizeFileName=${#1}
	if [ $? -ne ${sizeFileName} ]
	then
		if [[ "${1}" =~ [0-9a-zA-Z_]{3,20} ]]
		then
			status=1
		fi	
	fi
	echo $status
}


#========================================
# Check file exists
# @param $1 | filename config
#
checkFileExists() {
	status=false
	path="${PATH_CONFIG_NGINX}${1}.conf"

	if [ -f "${path}" ]
	then
		status=true
	fi
	echo $status
}


#=========================================
# create a new file and check file created 
# @param $1 | filename config
#
createFileConf () {
	path=${PATH_CONFIG_NGINX}${1}
	sudo touch "${path}.conf"
	check=$(checkFileExists ${1})
	if [ $check == "true" ]
	then
		echo -e "${GREEN}The file configuration was created.${COLOR_OFF}"
	else 
		echo -e "${RED}Has error while creating new file, please check again.${COLOR_OFF}"
	fi
}


#=========================================
# Check domain name is exists and create new domain name
#
createNewDomain () {
	read -p "Enter domain name : " domainName
	# Check domainName is exists 
	checkDomainNameExists=$(grep -c "${domainName}" ${PATH_HOSTS})
	while [[ checkDomainNameExists -ne 0 ]]
	do
		echo -e "${RED}Domain name is exists or is empty.${COLOR_OFF}"
		read -p "Please enter domain name again : " domainName
		checkDomainNameExists=$(grep -c "${domainName}" ${PATH_HOSTS})
	done

	read -p "Enter root project : " rootProject
	length=${#rootProject}
	while [[ $length -eq 0 ]]
	do
		echo -e "${RED}Please enter root path project.${COLOR_OFF}\n"
		read -p "Enter root project : " rootProject
		length=${#rootProject}
	done
	echo "127.0.0.1	${domainName}" | sudo tee -a ${PATH_HOSTS} >> /dev/null
content=$(cat << EOF
server {
	listen 80;
	server_name ${domainName};
	set \$MAGE_ROOT ${rootProject};
	include ${rootProject}/nginx.conf.sample;
}
EOF
)
	echo -e "${content}" | sudo tee -a ${path}.conf >> /dev/null
}



#=========================================
# Create sys link
#
createSymLink () {
	sudo ln -s ${PATH_CONFIG_NGINX}${1}.conf ${PATH_CONFIG_NGINX_SYMLINK}
}



# ========================================
# Create file configuration
# 
statusFileName=0
isFileNameExist=true
while [[ ${statusFileName} -eq 0 || ${isFileNameExist} == "true" ]]
do
	read -p "Enter filename configuration nginx : " name
	statusFileName=$(validateFileName ${name})
	if [[ ${statusFileName} -eq "0" ]]
	then
		echo -e "${RED}*** FAIL : file name is not correct format ***${COLOR_OFF}"
		echo -e "${YELLOW}Filename only contains characters, numbers, or underscore and length from 3 to 20 characters.${COLOR_OFF}"
		continue
	fi
	isFileNameExist=$(checkFileExists ${name})
	if [ ${isFileNameExist} == "true" ] 
	then
		echo -e "${RED}${PATH_CONFIG_NGINX}${name}.conf exists, please use other file name.${COLOR_OFF}\n"
	else 
		createFileConf $name
		createNewDomain
		createSymLink $name

		echo -e "${GREEN}Files configuration was created successfully.${COLOR_OFF}\n"
	fi
done


































