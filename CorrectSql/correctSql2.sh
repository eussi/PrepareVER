#!/bin/bash
# Program:
#       Correct insertion errors to esb SQL statements
# Author:
#       wangxueming 2018-08-17
#

########################################################
# FUNCTION
########################################################
#日志打印
function logger() {
	current=[`date "+%Y-%m-%d %H:%M:%S"`]
	echo "$current *$1"
}

#获取符合pattern的语句，并去除反斜杠
function getMatchLine() {
	awk "
		/$1/ {
			while(match(\$0, /\\\\/)>0) {
				sub(/\\\\\"/, \"${B}\")
			} 
			print \$0
		}
	" $2  #注意这里提替换了反斜杠加引号的操作
}

#获取字符串第n个Field
function getField() {
	echo $(echo $1 | awk -F "^" "{print \$$2}")
}

#传入协议信息，将调整后sql文件中协议信息替换
function replaceProMsg() {
	
	awk -v replFlag=${B} -v recordFile=$3 '
		FILENAME==ARGV[1] {
			if(match($0, /\(/)) {
				oldSql=substr($0, RSTART, length($0))
				split(oldSql, tempList, "'"\\\),\\\("'")
				for(i in tempList) {
					split(tempList[i], tempProList, "'"','"'")
					protocolTypeList[trim(tempProList[1])]=trim(tempProList[2])         #数组以协议名为键，type为值	
					protocolUrlList[trim(tempProList[1])]=trim(tempProList[3])         #数组以协议名为键，url为值
				}
			}
		}
		FILENAME==ARGV[2] {
			newSql=$0
			for(proName in protocolTypeList) {
				logger("正在处理第" ++m "个协议")
				proType=protocolTypeList[proName]
				proUrl=protocolUrlList[proName]
				proPattern="'"\\\([^\\\)]*"'" proName "'"[^\\\)]*"'" proType "'"[^\\\)]*\\\)"'"
				if(proType=="TCPChannelConnector") {
					replAttr="port=" replFlag "[0-9]*" replFlag			#replFlag为${B}
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
				}
				else if (proType=="TCPServiceConnector") {
					replAttr="port=" replFlag "[0-9]*" replFlag
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
					replAttr="host=" replFlag "[0-9.,]*" replFlag
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
				}
				else if (proType=="IbmQChannelConnector") {
					replAttr="queueName=" replFlag "[0-9a-zA-Z;_]*" replFlag
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
					replAttr="connectionFactory=" replFlag "[0-9a-zA-Z;_]*" replFlag
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
					replAttr="providerUrl=" replFlag "[0-9a-zA-Z;_.:\\/]*" replFlag
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
                                }
				else if (proType=="IbmQServiceConnector") {
                                        replAttr="queueName=" replFlag "[0-9a-zA-Z;_]*" replFlag
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
					replAttr="connectionFactory=" replFlag "[0-9a-zA-Z;_]*" replFlag
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
					replAttr="providerUrl=" replFlag "[0-9a-zA-Z;_.:=/]*" replFlag
					newSql=replaceAttr(newSql, proPattern, replAttr, proUrl)
                                } else {
					print "valid"
				}
				logger("第" m "个协议处理结束！")
			}
			print newSql > recordFile             #存入文件
		}	
                function trim(str) {
               		gsub(/^[(\047]*/, "", str)         #去除字符串两侧的括号和单引号
                      	gsub(/[(\047]*$/, "", str)
                	return str
              	}
		function replaceAttr(newStr, pattern, replPattern, url){
			if(match(newStr, pattern)) {				#匹配插入语句中某协议的语句并取出
				matchStr=substr(newStr, RSTART, RLENGTH)
				while(match(matchStr, replPattern)) {		#将取出的字符需要替换的模式传替换为####
					#print substr(matchStr, RSTART, RLENGTH)
					sub(replPattern, "####", matchStr)
				}
				sub(pattern, matchStr, newStr)			#将取出的字符串替换回去
			}	
			
			while(match(url, replPattern)) {			#取出要替换的内容替换####
				attr[++n]=substr(url, RSTART, RLENGTH)
				sub(replPattern, "", url)
				sub(/####/, attr[n], newStr)
			}
			return newStr
		}
		function logger(str) {	
			print "[20" strftime("%y-%m-%d %T", systime()) "] *    " str
			
		}
	' $1 $2
}

#调整sql语句顺序
function correctOrder() {
	#awk -v tableOrder=$1 -v logfile=$2 -f correctSql.awk $3
	awk -v tableOrder=$1 -v logfile=$2 '
		BEGIN {
			#从字符串中获取表顺序
			#originTables="v_dm_dwlsgx baseservices"
			#split(originTables, delOrder, " ")

			#从文件中获取表顺序
			orderfile=tableOrder
			getdelOrder(orderfile)

			newfile=logfile							#导出文件：new_filename
			begin=-1							#表操作是否开始
			end=-1								#表操作是否结束
			count=0								#存储抽取的表数

			logger("读取文件：" ARGV[1])
		}
		{
			oldData[0]=oldData[1]				#储存$0的前4行数据
			oldData[1]=oldData[2]
			oldData[2]=oldData[3]
			oldData[3]=oldData[4]
			oldData[4]=$0
		}
		begin<0 && end<0 {
			if(match($0, /^DROP TABLE /)) {			#输出dump文件开始的环境设置，遇到DROP TABLE停止
				begin=1
			} else {
				beginStr=beginStr $0 "\n"
			}
		}
		begin>0 {
			if(match($0, /^\-\- Final view/)) {		#输出dump文件结束的环境设置，遇到--  Final view开始
				endStr=oldData[3] "\n" $0 "\n"		#添加上一行"--" 
				end=1
				begin=-1
				tablesCreate[tablename]=substr(tablesCreate[tablename], 0, length(tablesCreate[tablename])-3)  #去除结尾多取的"--"

				#tablesCreate[tablename]=delLine(2, tablesCreate[tablename])
				#tablesCreate[tablename]=tablesCreate[tablename] "\n\n"                  #加上三行多余字符保持统一
				
				next
			}
			if(match($0, /^DROP TABLE /)) {
				tablename=$5
				tablename=substr(tablename, 2, length(tablename)-3)   #获取表名，作为数组的下标
				tables[tablename]=tables[tablename] $0                                                     #将DROP语句存放在tables数组中，其余信息存放在tablesCreate数组中
				tablesCreate[tablename]=oldData[0] "\n" oldData[1] "\n" oldData[2] "\n" oldData[3] "\n"
				#计数
				count++
			} 
			else if(begin>0) {
				tablesCreate[tablename]=tablesCreate[tablename] $0 "\n"
			}
		}
		end>0 {
			endStr=endStr $0 "\n"
		}
		END {	
			logger("文件：" ARGV[1] "读取结束")
			tableLen=length(delOrder)
			dataLen=length(tables)
			isExit=-1
			if(tableLen!=dataLen) {
				isExit=1
				logger("[" orderfile "]与["  ARGV[1] "]表数量不同！")
				logger("[" orderfile "]:" tableLen)
				logger("[" ARGV[1] "]:" dataLen)
			}
			logger("检测[" orderfile "]与["  ARGV[1] "]差异：")
			logger("[" ARGV[1] "]：")
			for(tarT in tables) {					  #读取文件包含的表
				fg=-1
				for(k in delOrder) {
					if(tarT==delOrder[k]) {
						fg=1
					}	
				}
				if(fg<0) {
					logger("--" tarT)
					isExit=1
				}
			}
			logger("[" orderfile "]：")
			for(l in delOrder) {					  #读取文件包含的表
				fg=-1
				for(destT in tables) {
					if(destT==delOrder[l]) {
						fg=1
					}	
				}
				if(fg<0) {
					logger("--" delOrder[l])
					isExit=1
				}
			}
			if(isExit>0) {
				logger("已异常退出")
				exit
			} else {
				logger("[" orderfile "]与["  ARGV[1] "]中表一致")
			}
			
			logger("存储数据至[" newfile "]")

			print beginStr | "head -n -5 >" newfile				#输出文件环境设置开始部分
			close("head -n -5 >" newfile)
			
			print "-- SQL for DROP TABLES\n" >> newfile			#按照表指定顺序倒序输出删除语句
			for(i=count;i>0;i--) { 
				print tables[delOrder[i]] >> newfile
			}
			
			print "\n\n-- SQL for CREATE TABLES\n"  >> newfile		#按照表指定顺序正序输出创建语句
			for(j in delOrder) {
				tablesCreate[delOrder[j]]=delLine(tablesCreate[delOrder[j]])
				print tablesCreate[delOrder[j]] >> newfile
			}
			
			print endStr >> newfile
			logger("存储完毕，查看[" newfile "]")

			close(newfile)
		}
		function getdelOrder(filename) {
			logger("读取文件：" filename)
			while("'"cat "'" filename "'" | grep -v '^$' | grep -v '^#' "'" | getline var) {
				delOrder[++n]=var
			}
			logger("文件：" filename "读取结束")
		}
		#去除多余的行
		function delLine(delStr) {
			delStr=substr(delStr,3,length(delStr))				#去除后再加上
			gsub(/\-\-\n\-\- Table structure.*\-\-\n/, "", delStr)
			return "--" delStr
		}
		function logger(str) {	
			print "[20" strftime("%y-%m-%d %T", systime()) "] *    " str
			
		}
	' $3
}

#替换insert语句
function replaceInsert() {
	> $4
	awk -v pattern="$3" -v finalFile="$4" '
		FILENAME==ARGV[1] {
			replace=$0
		}
		FILENAME==ARGV[2] {
			if(match($0, pattern)) {
				print replace >> finalFile
			} else {
				print $0 >> finalFile
			}
		}	
	' $1 $2
}

# MAIN
function main() {
	rm -f .tmp.*							#删除以前的临时文件

	#获取覆盖数据库插入语句
	logger "获取$oldSql插入语句"
	pattern='^INSERT INTO `protocolbind` VALUES'                    #匹配协议插入语句pattern
        getMatchLine "$pattern" $oldSql	> .tmp.old.$$

	#获取新文件数据库插入语句
	logger "获取$newSql插入语句"
	getMatchLine "$pattern" $newSql > .tmp.new.$$

	logger "开始协议信息替换"					#协议信息替换
	replaceProMsg ".tmp.old.$$" ".tmp.new.$$" ".tmp.replace.$$"
	# ${B}替换回 \"
	sed -i "s${A}${B}${A}\\\\\"${A}g" ".tmp.replace.$$"
	logger "替换结束！"
	
	logger "按照$tOrder调整表顺序"					#按照创建顺序表调整备份sql文件的删除和插入顺序
        correctOrder $tOrder ".tmp.final.$$" $newSql
	logger "调整结束"
	
	logger "替换生成文件$newGenSql插入语句"				#替换新文件协议内容
	replaceInsert ".tmp.replace.$$" ".tmp.final.$$" "$pattern" "$newGenSql"
	logger "替换结束！"

	rm -f .tmp.*							#删除临时文件
}

########################################################
# PROCEDURE
########################################################

if [ ! $# -eq 2 ]; then
	echo Usage: With two parameters, one is an old SQL file and the other is a new SQL file >&2
	exit 1
fi

A="`echo | tr '\012' '\001' `"		#sed replace delimiter
B="@"					#协议信息中反斜杠加引号不好处理，在这里转换

# VARIABLES
tOrder="tableOrder.txt"                 #正确表创建顺序
oldSql=$1                               #包含需要覆盖的库的插入protocolbind表语句文件
newSql=$2                               #navicat导出的备份sql语句文件
newGenSql="new_$newSql"

logger "*******************************************************"
logger "开始处理..."
main
logger "处理结束！"
logger "*******************************************************"
