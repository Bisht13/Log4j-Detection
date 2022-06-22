#!/bin/bash

# Set here the location of the folder to which the app's JAR files were copied.
T_CLASS_NAME="org/apache/logging/log4j/core/lookup/JndiLookup.class"
APP_LIBS_FOLDER=$1
WORK_FOLDER=/tmp/work
LIBS_COUNT=$(ls $APP_LIBS_FOLDER/*.jar | wc -l)

echo -e "\e[93m[+] Searching for the class '$T_CLASS_NAME' accross $LIBS_COUNT libraries...\e[0m"

find=0
find_one=0
i=0
cdir=$(pwd)

for lib in $APP_LIBS_FOLDER/*.jar
do
	i=$((i+1))

	echo -ne "\rInspecting file $i/$LIBS_COUNT..."

	find=$(unzip -l $lib | grep -c "$T_CLASS_NAME")
	if [ $find -ne 0 ]
	then
		find_one=1
		echo ""
		echo -e "\e[92m[!] Class found in the file '$(basename $lib)'.\e[0m"
		echo -e "\e[93m[+] Try to find the Maven artefact version...\e[0m"
		rm -rf $WORK_FOLDER 2>/dev/null
		mkdir $WORK_FOLDER
		unzip -q -d $WORK_FOLDER $lib
		cd $WORK_FOLDER
		for f in $(grep -r "groupId\s*=\s*org.apache.logging.log4j" *)
		do
			file_loc=$(echo $f | cut -d":" -f1)
			artefact_version=$(grep -Po "version\s*=\s*.*" $file_loc | sed 's/version=//g')
			echo "File          : $(basename $lib)"
			echo "Metadata file : $file_loc"
			echo "Log4J version : $artefact_version"
		done

		cd $cdir
		rm -rf $WORK_FOLDER 2>/dev/null
	fi
done
if [ $find_one -eq 0 ]
then
	echo -e "\e[91m[!] Class not found!\e[0m"
else
	echo -ne "\r\e[93m[+] Inspection finished.\e[0m"
fi
