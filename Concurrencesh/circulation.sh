#!/bin/bash
Njob=15 #任务总数
for((i=0;i<$Njob;i++))
do {
	echo "progress $i is sleeping for 3 seconds ..."
	sleep 3
}

done
echo -e "time-consuming:$SECONDS seconds" 
#$SECONDS 正常显示系统时间，在一个shell脚本中运行的话，每一次SECONDS从0开始，无需定义和read. bash默认SECONDS从0开始计时
