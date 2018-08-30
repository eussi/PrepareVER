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

#################################################
#(函数)返回执行命令的交易码
#arg1 传入交易码
#################################################
function returnResult() {
	cat $1 | grep $2 >/dev/null
	echo $?
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
print "[IN_SERVECE IN_PARSER IN_PACKER OUT_SERVICE OUT_PARSER OUT_PACKER]"
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
	#printTran "#交易码:$code"
	#in端
	inService=${deployPath}/configs/in_conf/metadata/define/service_${code}.xml
	inParser=${deployPath}/configs/in_conf/metadata/${channel}/channel_${channel}_service_${code}.xml
	inPacker=${deployPath}/configs/in_conf/metadata/${channel}/service_${code}_system_${channel}.xml
	outService=${deployPath}/configs/out_conf/metadata/${service}/service_${code}.xml
	outParser=${deployPath}/configs/out_conf/metadata/${service}/channel_${service}_service_${code}.xml
	outPacker=${deployPath}/configs/out_conf/metadata/${service}/service_${code}_system_${service}.xml
	#打印生成消息
	print "文件生成图："
	pr="[    "
	#判断是否已经存在
	result=$(returnResult ./temp/configs.txt inService)
	if [ "0" != ${result} ]; then
		printTran ${inService}
		pr="${pr}O          "
	else
		pr="${pr}X          "
	fi
	result=$(returnResult ./temp/configs.txt inParser)
	if [ "0" != ${result} ]; then
		printTran ${inParser}
		pr="${pr}O         "
	else
		pr="${pr}X         "
	fi
	result=$(returnResult ./temp/configs.txt inPacker)
	if [ "0" != ${result} ]; then
		printTran ${inPacker}
		pr="${pr}O          "
	else
		pr="${pr}X          "
	fi
	result=$(returnResult ./temp/configs.txt outService)
	if [ "0" != ${result} ]; then
		printTran ${outService}
		pr="${pr}O          "
	else
		pr="${pr}X          "
	fi
	result=$(returnResult ./temp/configs.txt outParser)
	if [ "0" != ${result} ]; then
		printTran ${outParser}
		pr="${pr}O          "
	else
		pr="${pr}X          "
	fi
	result=$(returnResult ./temp/configs.txt outPacker)
	if [ "0" != ${result} ]; then
		printTran ${outPacker}
		pr="${pr}O    ]"
	else
		pr="${pr}X    ]"
	fi
	print ${pr}
	print "交易码[$code]已正确生成配置文件"
done

print "结束生成配置文件列表文件:./temp/configs.txt"
printLine
