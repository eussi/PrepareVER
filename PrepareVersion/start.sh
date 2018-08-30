#!/bin/bash
# Program:
# 	读取config.properties中的相关配置
#	将fileList.txt中列出的文件复制到文件夹中
# Author:
# 	wangxueming
# Version:
# 	V1.0 2018-04-25
#################################################
#(函数)查找属性配置文件,得到value
#arg1 传入配置文件key
#################################################
function getConfigs() {
	cat ./configs/configs.properties  | grep -v '#' | grep "$1" | cut -d '=' -f 2
}

#################################################
#(函数)打印字符串，显示在控制台并写入run.log日志文件中 
#arg1 传入打印内容
#################################################
function print() {
	echo -e "$1" | tee -a run.log
}

#################################################
#(函数)打印*线
#################################################
function printLine() {
	echo "********************************************************" | tee -a run.log
}

#################################################
#(函数)打印系统环境参数
#################################################
info() {
	printLine
	print "System Information:"
	print
	print "$(uname -a)"
	print "CURRENT_TIME=$(date '+%Y%m%d%H%M%S')"
	printLine
}

#当前时间，格式20180414173254
current_time=$(date '+%Y%m%d%H%M%S')

#处理日志信息
if [ ! -d logs ]; then
	mkdir -p ./logs
fi
if [ -f run.log ]; then
	mv run.log ./logs/run.log.$current_time
fi
> run.log

#打印系统参数
info

#开始
print
print "版本准备开始..."

#得到生成文件路径
print
printLine
generateTarName=$(getConfigs generate.tar.name)
print "导出文件Tar包${generateTarName}生成位置:"
print "\t$(pwd)/${generateTarName}.$current_time.tar"

#临时目录位置
generatePath="./tempGenerate"
if [ ! -d $generatePath ]; then
	mkdir -p $generatePath
	if [ $? -eq "0" ]; then
#		print "\t$generatePath不存在,创建成功"
		print ""
	else
		print "\t$generatePath创建失败,已退出"
		exit 1
	fi
fi

#生成文件列表
. ./getTranFileList.sh


#拷贝列表文件
print
printLine
print "开始处理[fileList.txt]中配置文件"
for file in $(cat ./configs/fileList.txt | grep -v "#" | grep -v "^$")
do
	cp --parents $file $generatePath > /dev/null 2>&1
	if [ $? -eq "0" ]; then
		print "处理成功[$file]"
	else
		print "处理失败[$file]"
	fi
done
print "结束处理[fileList.txt]中配置文件"
printLine

#拷贝交易码配置文件
print
printLine
print "开始处理[tranCode.txt]中生成配置文件"
for file in $(cat ./temp/configs.txt | grep -v "#" | grep -v "^$")
do
        cp --parents $file $generatePath > /dev/null 2>&1
        if [ $? -eq "0" ]; then
		print "处理成功[$file]"
        else
		print "处理失败[$file]"
        fi
done
print "结束处理[tranCode.txt]中生成配置文件"
printLine

#统计失败数
print
printLine
print "处理文件总数:[$(grep -E "成功|失败" run.log | wc -l)]"
print "成功文件数:[$(grep "成功" run.log | wc -l)]"
print "失败文件数:[$(grep "失败" run.log | wc -l)]"
printLine

#将generatePath打包成tar,删除生成文件夹
print
printLine
print "删除旧Tar包,正在生成Tar包"
rm -rf *.tar
cd $generatePath
tar -cvf ../${generateTarName}.$current_time.tar * > /dev/null 2>&1
cd ..
rm -rf $generatePath
print "已生成$generateTarName,请查看$(pwd)/${generateTarName}.${current_time}.tar..."
printLine

print  "版本准备结束..."
print
printLine
