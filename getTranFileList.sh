#!/bin/bash
# Program:
#       读取tranCode.txt中的交易码
#       生成相应的文件交易配置文件列表
# Author:
#       wangxueming
# Version:
#       V1.0 2018-04-25
#################################################
#(函数)打印正在处理的交易码
#arg1 传入交易码
#################################################
function printTran() {
	echo -e $1 >> ./temp/configs.txt
}

#得到ESB部署路径
deployPath=$(getConfigs deploy.path)
print "ESB部署路径:"
print "\t$deployPath"
print ""
printLine

print
printLine
print "开始生成配置文件列表文件:./temp/configs.txt"

> ./temp/configs.txt
printTran "#交易文件列表"
#循环交易码
for tranCode in $(cat ./configs/tranCode.txt | grep -v "#" | grep -v "^$")
do	
	code=$(echo $tranCode | grep ":" | cut -d ":" -f 1)
	channel=$(echo $tranCode | grep ":" | cut -d ":" -f 2)
	service=$(echo $tranCode | grep ":" | cut -d ":" -f 3)
	if [ -z "$code" -o -z "$channel" -o -z "$service" ]; then
		print "./configs/tranCode.txt文件[$tranCode]配置错误,退出程序"
		printLine
		exit 1
	fi
	#生成路径,紫金农商银行业务规则
	printTran "#交易码:$code"
	#in端
	printTran "${deployPath}/configs/in_conf/metadata/define/service_${code}.xml"
	printTran "${deployPath}/configs/in_conf/metadata/${channel}/channel_${channel}_service_${code}.xml"
	printTran "${deployPath}/configs/in_conf/metadata/${channel}/service_${code}_system_${channel}.xml"
	#out端
	printTran "${deployPath}/configs/out_conf/metadata/${service}/service_${code}.xml"
	printTran "${deployPath}/configs/out_conf/metadata/${service}/channel_${service}_service_${code}.xml"
        printTran "${deployPath}/configs/out_conf/metadata/${service}/service_${code}_system_${service}.xml"
	print "交易码[$code]已正确生成配置文件"
done

print "结束生成配置文件列表文件:./temp/configs.txt"
printLine
