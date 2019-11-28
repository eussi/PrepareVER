#!/bin/bash
#program:
#	Install Distributed EUSSIAgent
#author:
#	wangxmx 2019.11.06
#################################
#define here
LANGUAGE=zh_CN.utf8
JAVA_VERSION=7
INSTALL_PATH=`echo $HOME | sed 's/\/$//'`     #home dir of run user

EUSSI_TERMINAL_SYSTEM=TPYCNB
EUSSI_TERMINAL_ID=TPYCNB001
EUSSI_TERMINAL_IP=`ifconfig | sed -n '/^lo/!{n;/[^0-9]*\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*/s//\1/p}'` #get this server's IP
EUSSI_ZOOKEEPER_URLS=192.168.198.128:2181
EUSSI_TERMINAL_DEPLOY=0

echo -e "Install EUSSIAgent Begin...\n-----------------------------"
echo "Check Data List:"
echo "	LANGUAGE=$LANGUAGE"
echo "	JAVA_VERSION=$JAVA_VERSION"
echo "	INSTALL_PATH=$INSTALL_PATH"
echo "	EUSSI_TERMINAL_SYSTEM=$EUSSI_TERMINAL_SYSTEM"
echo "	EUSSI_TERMINAL_ID=$EUSSI_TERMINAL_ID"
echo "	EUSSI_TERMINAL_IP=$EUSSI_TERMINAL_IP"
echo "	EUSSI_ZOOKEEPER_URLS=$EUSSI_ZOOKEEPER_URLS"
echo "	EUSSI_TERMINAL_DEPLOY=$EUSSI_TERMINAL_DEPLOY"

#################################
echo "Check EUSSIAgent.zip exists?"
if [ ! -f $INSTALL_PATH/EUSSIAgent.zip ] && [ ! -d $EUSSI_INSTALL_PATH/EUSSIAgent/ ]; then  #should have one or all of them
	echo "	FAIL. EUSSIAgent dir and EUSSIAgent.zip not exits, please upload them to $INSTALL_PATH"
	exit -1
else 
	echo "	SUCC. EUSSIAgent dir or EUSSIAgent.zip exist"
fi
#############################################
echo Check the variable LANG=LANGUAGE?
if [ "$LANGUAGE" = `echo $LANG` ]; then
	echo "	SUCC. "
else
	echo "	FAIL. LANG=`echo $LANG`"
	exit -1
fi
#####################
echo "Check java version=$JAVA_VERSION?"
#CURRENT_VERSION=`"${JAVA_HOME}/bin/java" -version 2>&1 | awk -F'"' '/version/ {gsub("^1[.]", "", $2); gsub("[^0-9].*$", "", $2); print $2}'`
CURRENT_VERSION=`"${JAVA_HOME}/bin/java" -version 2>&1 | sed -n '/version/{s/.*"[0-9]\{1,\}\.\([0-9]\{1,\}\).*/\1/p}'`
if [ -z $CURRENT_VERSION ]; then
	echo "	FAIL. please install JAVA[$JAVA_VERSION]"
	exit -1
elif [ $JAVA_VERSION -eq $CURRENT_VERSION ]; then
	echo "	SUCC."
else
	echo "	FAIL. please install JAVA[$JAVA_VERSION]"
	exit -1
fi
#############################
echo "Check the variable EUSSI_INSTALL_PATH=$INSTALL_PATH?"
if [ "$EUSSI_INSTALL_PATH" = "$INSTALL_PATH" ]; then
        echo "	SUCC. "
else
        echo "	FAIL. EUSSI_INSTALL_PATH==$EUSSI_INSTALL_PATH"
        exit -1
fi
############################
echo "Check if unzip are installed?"
unzip > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "	SUCC. "
else
	echo "	FAIL. please install unzip"
	exit -1
fi
###########################
echo "Unzip EUSSIAgent.zip successfully?"
if [ -d $EUSSI_INSTALL_PATH/EUSSIAgent/ ]; then
	echo "	SUCC. EUSSIAgent.zip unziped, skip this step"
else
	unzip EUSSIAgent.zip
	if [ -d $EUSSI_INSTALL_PATH/EUSSIAgent/ ]; then
		echo "	SUCC. unzip EUSSIAgent.zip successfully"
		chmod -R 755 $EUSSI_INSTALL_PATH/EUSSIAgent
		if [ $? -eq 0 ]; then
			echo "	SUCC. chmod 755 $EUSSI_INSTALL_PATH/EUSSIAgent"
		else 
			echo "	FAIL. chmod 755 $EUSSI_INSTALL_PATH/EUSSIAgent"
			exit -1
		fi
	else
		echo "	FIAL. unzip EUSSIAgent.zip"
		exit -1
	fi
fi
##############################
echo "Check agentDaemon.sh's config is right?"
if [ `whoami` = `sed -n  '/^EUSSIUser=\([a-zA-Z][a-zA-Z]*\)/s//\1/p' $EUSSI_INSTALL_PATH/EUSSIAgent/agentDaemon.sh` ]; then
	echo "	SUCC. agentDaemon.sh's EUSSIUser config right"
else
	echo "  FAIL. agentDaemon.sh's EUSSIUser not `whoami`, script will set it"
	sed -i '/^\(EUSSIUser=\)[a-zA-Z][a-zA-Z]*/s//\1'"$(whoami)"'/' $EUSSI_INSTALL_PATH/EUSSIAgent/agentDaemon.sh
	if [ $? -eq 0 ]; then
		echo "	SUCC. agentDaemon.sh's EUSSIUser already set it"
	else
		echo "	FAIL. agentDaemon.sh's EUSSIUser set fail"
	fi
fi
if [ $EUSSI_INSTALL_PATH = `sed -n  '/^EUSSI_INSTALL_PATH=\([a-zA-Z/][a-zA-Z/]*\)/s//\1/p' $EUSSI_INSTALL_PATH/EUSSIAgent/agentDaemon.sh` ]; then
        echo "	SUCC. agentDaemon.sh's EUSSI_INSTALL_PATH config right"
else
	echo "	FAIL. agentDaemon.sh's EUSSI_INSTALL_PATH not $EUSSI_INSTALL_PATH, script will set it"
        sed -i '/^\(EUSSI_INSTALL_PATH=\)[a-zA-Z\/][a-zA-Z\/]*/s!!\1'"$INSTALL_PATH"'!' $EUSSI_INSTALL_PATH/EUSSIAgent/agentDaemon.sh
	if [ $? -eq 0 ]; then
		echo "  SUCC. agentDaemon.sh's EUSSI_INSTALL_PATH already set it"
	else
		echo "  FAIL. agentDaemon.sh's EUSSI_INSTALL_PATH set fail"
	fi
fi
################################
BACK_STR=$(date '+%Y-%m-%d_%H-%M-%S')
echo Check and modify agent.properties
#backup
cp $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties.bak$BACK_STR
echo "	SUCC. backup $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties to $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties.bak$BACK_STR"
sed -i 's/\(EUSSI.terminal.system=\)[a-zA-Z0-9][a-zA-Z0-9]*/\1'"$EUSSI_TERMINAL_SYSTEM"'/' $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties
echo "	SUCC. update EUSSI.terminal.system=$EUSSI_TERMINAL_SYSTEM"
sed -i 's/\(EUSSI.terminal.id=\)[a-zA-Z0-9][a-zA-Z0-9]*/\1'"$EUSSI_TERMINAL_ID"'/' $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties
echo "	SUCC. update EUSSI.terminal.id=$EUSSI_TERMINAL_ID"
sed -i 's/\(EUSSI.terminal.ip=\)[0-9\.][0-9\.]*/\1'"$EUSSI_TERMINAL_IP"'/' $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties
echo "	SUCC. update EUSSI.terminal.ip=$EUSSI_TERMINAL_IP"
sed -i 's/\(EUSSI.zookeeper.urls=\)[0-9\.:,][0-9\.:,]*/\1'"$EUSSI_ZOOKEEPER_URLS"'/' $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties
echo "	SUCC. update EUSSI.zookeeper.urls=$EUSSI_ZOOKEEPER_URLS"
sed -i 's/\(EUSSI.terminal.deploy=\)[0-9][0-9]*/\1'"$EUSSI_TERMINAL_DEPLOY"'/' $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties
echo "	SUCC. update EUSSI.terminal.deploy=$EUSSI_TERMINAL_DEPLOY"
echo "	SUCC. updated $EUSSI_INSTALL_PATH/EUSSIAgent/conf/agent.properties finished"

################################
echo Check and modify startAgent.sh
cp $EUSSI_INSTALL_PATH/EUSSIAgent/startAgent.sh $EUSSI_INSTALL_PATH/EUSSIAgent/startAgent.sh.bak$BACK_STR
echo "	SUCC. backup $EUSSI_INSTALL_PATH/EUSSIAgent/startAgent.sh to $EUSSI_INSTALL_PATH/EUSSIAgent/startAgent.sh.bak$BACK_STR"
sed -i 's/\(.*java.rmi.server.hostname=\)[0-9a-zA-Z\.][0-9a-zA-Z\.]*\( .*\)/\1'"$EUSSI_TERMINAL_IP"'\2/' $EUSSI_INSTALL_PATH/EUSSIAgent/startAgent.sh
echo "	SUCC. update java.rmi.server.hostname=$EUSSI_TERMINAL_IP"
echo "	SUCC. updated $EUSSI_INSTALL_PATH/EUSSIAgent/startAgent.sh finished"

#################################
echo Add crontab
crontab -l | grep "$EUSSI_INSTALL_PATH/EUSSIAgent/agentDaemon.sh" > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "	SUCC. crontab /data/app/EUSSI/EUSSIAgent/agentDaemon.sh has exists, skip this step"
else 
	echo -e  "`crontab -l`\n* * * * * sh /data/app/EUSSI/EUSSIAgent/agentDaemon.sh" | crontab
	if [ $? -eq 0 ]; then
		echo "	SUCC. append crontab * * * * * sh /data/app/EUSSI/EUSSIAgent/agentDaemon.sh successfully"
	else
		echo "	FAIL. append crontab * * * * * sh /data/app/EUSSI/EUSSIAgent/agentDaemon.sh failed"
		exit -1
	fi
fi

echo "-----------------------------"
echo "Install EUSSIAgent END."
