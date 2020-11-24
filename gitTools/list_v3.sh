#!/bin/bash
#program:
#  Switch application directory
#author:
#  xuemingwang 2020-11-21
#usage:
#  source list_v3.sh dir -g
#  source list_v3.sh dir -l
#  source list_v3.sh dir -s str

#print format
WHITE="\033[37m"
RED="\033[31m"
BOLD="\033[1m"

#params
INPUT_PARAMS=$@
INPUT_PARAMS_NUM=$#

#variable
TEMP_FILE=/.list_v3
ROOT_DIR=$1
FLAG=$2
FLAG_VALUE=$3
APP_FILENAME=app.properties
APPID_SYMPOL=app.id
NULL_APPID=#########

#print func
printMsg() {
    mesg=$1
    head=$2
    tail=$3
    echo -e "${head}${mesg}${tail}"
}

getAppId() {
    rootDir=$1
    filePath=$ROOT_DIR'/'$rootDir'/src/main/resources/META-INF/'$APP_FILENAME
    #src\main\resources\META-INF\app.properties
    if [ -f "$filePath" ]; then
        echo `sed -n '/^'"$APPID_SYMPOL"'=\([0-9]*\)/s//\1/p' $filePath`
    else
        find=0
        for var in `ls $ROOT_DIR'/'$rootDir`
        do
            secondFilePath=$ROOT_DIR'/'$rootDir'/'$var'/src/main/resources/META-INF/'$APP_FILENAME
	    #echo $secondFilePath
	    if [ -f "$secondFilePath" ]; then
                echo `sed -n '/^'"$APPID_SYMPOL"'[ ]*=[ ]*\([0-9]*\)/s//\1/p' $secondFilePath`
                find=1
		break  #At most two layer
            fi
	done
	if [ $find = "0" ]; then
            echo $NULL_APPID
        fi
    fi
}

#Generate temporary cache
generate() {
    tempFile=$TEMP$TEMP_FILE
	> $tempFile
	index=0
    for var in `ls $ROOT_DIR`
    do
	    subDir=$ROOT_DIR"/"$var
	    if [ ! -d $subDir ]; then
            continue
	    fi
	    appId=`getAppId $var`
	    printf "%-9s %s\n" "$appId" "$var" >> $tempFile
	    index=$((index+1))
    done

}

#List the options
list() {
    tempFile=$TEMP$TEMP_FILE
	if [ ! -f $tempFile ]; then
	    echo "err: need a temporary document."
	else
	    echo -e "\nLIST:"
	    index=0
        while read line
	    do
		    app_arr[index]=`printf "%02s %s" "$index" "$line"`
		    echo ${app_arr[index]}
		    index=$((index+1))
	    done < $tempFile
		echo -e "\nOPTIONS:"
		while true
        do
	        echo Please choose where to go or exit by Q:
            read input
	        #echo $input
	        if [ "Q" = "$input" -o "q" = "$input" ]; then
	            echo "exit"
	            #exit 0
	            break
	        fi
	        find=0
	        for ((k=0; k<$index; k++))
	        do
                echo "${app_arr[$k]}" | grep "$input" > /dev/null 2>&1
	            if [ $? -eq 0 ]; then
                    #find
		            find=1
		            retDir=`echo ${app_arr[$k]} | awk '{print $3}'`
                    cd $ROOT_DIR"/"$retDir
		            echo -e "\nCURRENT: "$ROOT_DIR"/"$retDir
		            break
	            fi
            done
	        #for remove exit
	        if [ "$find" = "1" ]; then
	            break
	        fi
	        echo -e "Please enter the string contained in the list.\n"
        done
	fi
}

#Switch directory
switch(){
    tempFile=$TEMP$TEMP_FILE
	if [ ! -f $tempFile ]; then
	    echo "err: need a temporary document."
	else
	    find=0
        while read line
	    do
		    echo "$line" | grep "$FLAG_VALUE" > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				#find
				find=1
				retDir=`echo ${line} | awk '{print $2}'`
				cd $ROOT_DIR"/"$retDir
				echo -e "\nCURRENT: "$ROOT_DIR"/"$retDir
				break
			fi
	    done < $tempFile
		if [ "$find" != "1" ]; then
	        echo -e "No such app dir.\n"
	    fi
	    
	fi
}


#main
main() {
	if [[ $FLAG != -* ]]; then
		FLAG_VALUE=$FLAG
		FLAG="-s" #default value -s
	fi
	
	case $FLAG in
	    "-l")
		    list
			;;
		"-g")
		    generate
			;;
		"-s")
		    switch
			;;
		*)
		    echo "Unsupported commands."
		;;
	esac
}

#basic check
if [ $# -gt 3 ]; then
    echo Usage: Up to three parameters, root_dir, flag and the value.
    #exit -1 #Exit cannot be used in order to switch execution directories
else
    if [ ! -d $ROOT_DIR ]; then
        echo $ROOT_DIR "is not exist."
        #exit -1  #Exit cannot be used in order to switch execution directories
    else
        if [ ! -d $ROOT_DIR ]; then
	        echo $ROOT_DIR "is not exist."
	    else
	        main
	    fi
    fi
fi

