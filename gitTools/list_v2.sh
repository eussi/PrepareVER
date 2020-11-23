#!/bin/bash
#program:
#  Switch application directory
#author:
#  xuemingwang 2020-11-21
#usage:
#  source list_v2.sh dir  

#print format
WHITE="\033[37m"
RED="\033[31m"
BOLD="\033[1m"

#print func
printMsg() {
    mesg=$1
    head=$2
    tail=$3
    echo -e "${head}${mesg}${tail}"
}


ROOT_DIR=$1
APP_FILENAME=app.properties
APPID_SYMPOL=app.id
NULL_APPID=#########

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


#main
main() {
    echo ""
    echo "******************************"
    printMsg "APP_DIR:$ROOT_DIR" $WHITE $BOLD
    echo "******************************"
    #get list
    echo -e "\nLIST:"
    index=0
    for var in `ls $ROOT_DIR`
    do
	subDir=$ROOT_DIR"/"$var
	if [ ! -d $subDir ]; then
            continue
		
	fi
	#find appid
	#appfilePath=`find $subDir \( -path "./.git" -o -path ".git" -o -path "./.idea" \) -prune -o -name $APP_FILENAME`
	appId=`getAppId $var`

        #if [ -n "$appfilePath" ]; then
	#    app_arr[index]="["$index"]. "`sed -n '/^'"$APPID_SYMPOL"'=\([0-9]*\)/s//\1/p' $appfilePath`" "$var
        #else
	#    app_arr[index]="["$index"]. "$NULL_APPID" "$var
	#fi

	app_arr[index]=`printf "[%02s]. %-9s %s" "$index" "$appId" "$var"`
        printMsg "${app_arr[index]}" $WHITE $BOLD
	
	#echo "${app_arr[index]}"
	index=$((index+1))
    done
    #print list
    #for ((k=0; k<$index; k++))
    #do
    #    printMsg "${app_arr[$k]}" $WHITE $BOLD
    #done
    #choose where to to
    echo "******************************"
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
}


if [ ! $# -eq 1 ]; then
    echo Usage: with one parameters, the root of application directory.
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

