# AUTHOR: Cereal
# DATA:   04-11-2011
# VERSION: 0.2

# DISCLAIMER : I AM NOT RESPONSIBLE FOR ANY DAMAGE TO YOUR PHONE AND DO AT YOUR OWN RISK 

# DESCRIPTION
#
# This script is used to flash automatically the stock rom on Android's smartphone and/or the 
# ClockWorkMod using Heimdall software in Linux OS.
# 
# The script check if Heimdall software is installed and after that check if the device is detected, if isn't the
# script exit because it can't flash the device.
# If everything is ok the script checks if there are the necessary files.
# About stock rom you need :
#
#	PIT File
#	boot.bin	<- Primary Boot
#	Sbl.bin		<- Secondary Boot
#	normalboot.img	<- Normal Boot
#	cache.rfs	<- Cache
#	modem.bin	<- Modem
#	param.lfs	<- Param
#	system.rfs	<- System
#
# About ClockWorkMod you need :
#
#	normalboot.img 	<- Normal Boot
#	param.lfs	<- Param

# IMPORTANT
# This script it was tested only on Samsung I9003 and stock roms XXKE and XXKM and the ClockWorkMod for XXKPM ( Skin1980 ).

# USAGE
#
# Give the execute permission typing :
#
#	chmod +x auto_flash.sh
#
# Extract the files from the archive/s in order to have all the files in the same directory.
#
# Type the following command :
#
# 	sh auto_flash.sh <directory>
#
# The <directory> will be that one that contains the files wrote upper. If the files and the script are 
# both in the same directory leave this parameter blank. So type :
#
# 	sh auto_flash.sh
#
# After that you see the menu where you can choose to flash a stock rom or the clockworkmod.
# For some stock rom it is requested to repartition so after all checks you'll be asked if to repartition
# if you want to.

##################################################################################################################

# List of files you need to flash correctly a stock rom ( it works in XXKPE and XXKPM)
Files[1]="boot.bin"
Files[2]="Sbl.bin"
Files[3]="normalboot.img"
Files[4]="cache.rfs"
Files[5]="modem.bin"
Files[6]="param.lfs"
Files[7]="system.rfs"


# Check if Heimdall is installed 
check_heimdall()
{
	if command -v heimdall >/dev/null 
	then
		echo "Heimdall $(tput setaf 2) INSTALLED $(tput sgr0)"
	else
		echo "Heimdall $(tput setaf 1) FAIL $(tput sgr0)"
		echo "Heimdall not found, install it."
		exit 1
	fi
}

# Check if Heimdall detect your device
check_detect()
{
	if heimdall detect | grep -e detected
	then
		echo "Device detected $(tput setaf 2) OK $(tput sgr0)"
	else
		echo "Device detected $(tput setaf 1) FAIL $(tput sgr0)"
		echo "Check if the device is in download mode."
		#exit 1
	fi
}

# Check if there are all files in the path
files_stock_rom()
{
	found=true
	for i in 1 2 3 4 5 6 7;do
	
		check_file="$path""${Files[i]}"
		if [ -f $check_file ]
		then
		    echo "${Files[i]} $(tput setaf 2) FOUND $(tput sgr0)"
		else
		    echo "${Files[i]} $(tput setaf 1) MISSING $(tput sgr0)"
		    found=false
		fi
	done
	
	pit_file=$(ls $path | grep .pit)
	
	# Check the existence of PIT file
	if [ -n "$pit_file" ]
	then
		echo "PIT File $(tput setaf 2) FOUND $(tput sgr0)"
	else
		echo "PIT File $(tput setaf 1) MISSING $(tput sgr0)"
		found=false
	fi

	if ! $found
	then
		echo "File missing."
		exit 1
	fi
}

# Execute the command to flash the device
flash_stock_rom()
{
	echo 
	echo "You want do repartition ? [y/n]"
	read ANSWER
	

	if [ $ANSWER = 'y' ]
	then
		repartition="--repartition"
	else
		repartition=""
	fi

	flash_cmd="heimdall flash ""$repartition"" --pit "$path""$pit_file" --primary-boot ""$path""${Files[1]}"" --secondary-boot ""$path""${Files[2]}"" --normal-boot 		""$path""${Files[3]}"" --cache ""$path""${Files[4]}"" --modem ""$path""${Files[5]}"" --param ""$path""${Files[6]}"" --system ""$path""${Files[7]}"

	echo $flash_cmd

	if command $flash_cmd 
	then
		echo "FLASH STOCK ROM $(tput setaf 2) DONE $(tput sgr0)"
		echo "Remember to got in recovery mode vol up + home + power"
	else
		echo "FLASH STOCK ROM $(tput setaf 1) FAIL $(tput sgr0)"
	fi
}


# Check if there are all files in the path
files_cwm()
{

	found=true
	check_param="$path""${Files[6]}"
	if [ -f $check_param ]
	then
	    echo "${Files[6]} $(tput setaf 2) FOUND $(tput sgr0)"
	else
	    echo "${Files[6]} $(tput setaf 1) MISSING $(tput sgr0)"
	    found=false
	fi
	
	check_normalboot="$path""${Files[3]}"
	if [ -f $check_normalboot ]
	then
	    echo "${Files[3]} $(tput setaf 2) FOUND $(tput sgr0)"
	else
	    echo "${Files[3]} $(tput setaf 1) MISSING $(tput sgr0)"
	    found=false
	fi
	

	if ! $found
	then
		echo "File missing."
		exit 1
	fi

}

flash_cwn()
{
# Execute the command to flash the device


	flash_cmd="heimdall flash  --normal-boot ""$path""${Files[3]}"" --param ""$path""${Files[6]}"

	#echo $flash_cmd

	if command $flash_cmd 
	then
		echo "FLASH CWN $(tput setaf 2) DONE $(tput sgr0)"
		echo "Remember to got in recovery mode vol up + home + power"
	else
		echo "FLASH CWN $(tput setaf 1) FAIL $(tput sgr0)"
	fi

}


rom_stock(){


	check_heimdall
	check_detect
	files_stock_rom path path
	flash_stock_rom


}

cwm(){
	check_heimdall
	check_detect
	files_cwm path path
	flash_cwn path path
}

# Path where we can, hopefully, find the files
path=$1

command clear
echo "Heimdall Auto Version 0.2"

echo
echo "Menu"
echo "1) Flash Stock Rom"
echo "2) Flash CWM"
echo "3) Quit" 
echo 
read option

case $option in
	1) rom_stock path;;
	2) cwm path;;
	3) ;;
	*) echo "Option unknow";;
esac


exit 

