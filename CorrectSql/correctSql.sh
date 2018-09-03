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

#获取符合pattern的语句
function getMatchLine() {
	proInsert=$(awk "/$1/ {print \$0}" $2)
        proInsert=${proInsert:${#1}}
	echo $proInsert
}

#获取字符串第n个Field
function getField() {
	echo $(echo $1 | awk -F "^" "{print \$$2}")
}

#整理协议信息
function formatProMsg() {
	echo $(echo $1 | awk -F "','"  '
                        BEGIN{
                                RS="\\),\\("
                        }
                        {
                                $1=trim($1)
                                $2=trim($2)
                                $3=trim($3)
                                printf("%s^%s^%s|", $1, $2, $3)    #输不出换行，待解决，用"|"代替，使用时再替换
                        }
                        function trim(str) {
                                gsub(/^[(\047]*/, "", str)         #去除字符串两侧的括号和单引号
                                gsub(/[(\047]*$/, "", str)
                                return str
                        }    
                ')
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

#替换属性内容
function replaceAttr() {            #第五个参数传入要匹配的正则表达式即可, 处理速度较慢，待完善
	attrs=$(echo $3 | awk "{while(match(\$0, /$4/)>0) { print substr(\$0, RSTART, RLENGTH);sub(/$4/, \"\");}}")
	oneReplace=$(echo $1 | awk "{
		if(match(\$0, /$2/ )) {
			matchStr=substr(\$0, RSTART, RLENGTH)
			while(match(matchStr, /$4/)>0) {
				#print substr(matchStr, RSTART, RLENGTH)
				sub(/$4/, (\"##\" ++n \"##\"), matchStr)	
			}
			sub(/$2/, matchStr)
			print \$0
		}		
	}")

	n=1
	A="`echo | tr '\012' '\001' `"
	for attr in $attrs
	do	
		attr=$(echo $attr | sed 's/\\/\\\\/g')
		oneReplace=$(echo $oneReplace | sed "s${A}##$n##${A}$attr${A}") #常规定界符"/"与providerURL冲突
		n=$((n+1))
	done
	echo $oneReplace
}

#传入协议信息，将调整后sql文件中协议信息替换
function replaceProMsg() {
	#echo "$1" | sed 's/\\/\\\\/g;s/|/\n/g' | sed '/^$/d' | while read line # 通过管道会创建子shell，变量无法传递给父shell
	##################################
	#解决方式一：通过命名管道进程间通信
	##################################
	#mkfifo ./fifo.$$ && exec 777<>./fifo.$$ && rm -f ./fifo.$$ #通过文件插述符777访问fifo文件
	#echo "$1" | sed 's/\\/\\\\\\\\/g;s/|/\n/g' | sed '/^$/d' | while read line 
	#do
	#	echo $line >&777
	#done
	#echo "exit" >&777
	#
	#proNum=0
	#while read -u 777 line
	#do
	#	if [ "exit" == "$line" ]; then
	#		break
	#	fi
	#	proNum=$((proNum+1))
	#	logger "    正在处理第$proNum条协议信息"
	#	name=`getField "$line" 1`
	#	type=`getField "$line" 2`
	#	url=`getField "$line" 3`
	#	proPattern="\\([^\\\\)]*$name[^\\)]*$type[^\\)]*\\)"
	#	
	#	case $type in
	#		"TCPChannelConnector")				#替换port
	#			portAttr="port=\\\\\"[0-9]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$portAttr")
	#			#replaceAttr "$insertGloVar" $proPattern "$url" "$portAttr" 
	#			;;
	#		"TCPServiceConnector")				#替换port、host
	#			portAttr="port=\\\\\"[0-9]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$portAttr")
	#			ipAttr="host=\\\\\"[0-9.,]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$ipAttr")
	#			;;
	#		"IbmQChannelConnector")				#替换queueName、connectionFactory、providerUrl
	#			queueNameAttr="queueName=\\\\\"[0-9a-zA-Z;_]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$queueNameAttr")
	#			connectionFactoryAttr="connectionFactory=\\\\\"[0-9a-zA-Z;_]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$connectionFactoryAttr")
	#			providerUrlAttr="providerUrl=\\\\\"[0-9a-zA-Z;_.:\/]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$providerUrlAttr")
	#			;;
	#		"IbmQServiceConnector")				#替换queuname、connectionFactory、providerUrl
	#			queueNameAttr="queueName=\\\\\"[0-9a-zA-Z;_]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$queueNameAttr")
	#			connectionFactoryAttr="connectionFactory=\\\\\"[0-9a-zA-Z;_]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$connectionFactoryAttr")
	#			providerUrlAttr="providerUrl=\\\\\"[0-9a-zA-Z;_.:\/]*\\\\\""
	#			insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$providerUrlAttr")
	#			;;
	#		*)
	#			echo valid
	#			;;
	#	esac
	#	logger "    第$proNum条协议信息处理完毕"
	#done
	#exec 777>&-  #关闭文件描述符的写
	#exec 777<&-  #关闭文件描述符的读
	#
	#######################################
	#解决方式二：重定向到一个文件，去除管道
	########################################
	echo "$1" | sed 's/\\/\\\\/g;s/|/\n/g' | sed '/^$/d' >.tmp.$$
	proNum=0
	while read line
	do
		proNum=$((proNum+1))
		logger "    正在处理第$proNum条协议信息"
		name=`getField "$line" 1`
		type=`getField "$line" 2`
		url=`getField "$line" 3`
		proPattern="\\([^\\\\)]*$name[^\\)]*$type[^\\)]*\\)"
		
		case $type in
			"TCPChannelConnector")				#替换port
				portAttr="port=\\\\\"[0-9]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$portAttr")
				#replaceAttr "$insertGloVar" $proPattern "$url" "$portAttr" 
				;;
			"TCPServiceConnector")				#替换port、host
				portAttr="port=\\\\\"[0-9]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$portAttr")
				ipAttr="host=\\\\\"[0-9.,]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$ipAttr")
				;;
			"IbmQChannelConnector")				#替换queueName、connectionFactory、providerUrl
				queueNameAttr="queueName=\\\\\"[0-9a-zA-Z;_]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$queueNameAttr")
				connectionFactoryAttr="connectionFactory=\\\\\"[0-9a-zA-Z;_]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$connectionFactoryAttr")
				providerUrlAttr="providerUrl=\\\\\"[0-9a-zA-Z;_.:\/]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$providerUrlAttr")
				;;
			"IbmQServiceConnector")				#替换queuname、connectionFactory、providerUrl
				queueNameAttr="queueName=\\\\\"[0-9a-zA-Z;_]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$queueNameAttr")
				connectionFactoryAttr="connectionFactory=\\\\\"[0-9a-zA-Z;_]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$connectionFactoryAttr")
				providerUrlAttr="providerUrl=\\\\\"[0-9a-zA-Z;_.:\/]*\\\\\""
				insertGloVar=$(replaceAttr "$insertGloVar" $proPattern "$url" "$providerUrlAttr")
				;;
			*)
				echo valid
				;;
		esac
		logger "    第$proNum条协议信息处理完毕"
	done < .tmp.$$
	rm -f .tmp.$$
}

# MAIN
function main() {
	#获取覆盖数据库插入语句
	logger "获取$oldSql插入语句"
	pattern='^INSERT INTO `protocolbind` VALUES'                    #匹配协议插入语句pattern
        proInsert=$(getMatchLine "$pattern" $oldSql)
	
	#存储协议的各项信息，每个协议内部之间通过"^"分隔，每个协议通过"|"分隔
        logger "处理获取数据协议信息"
	oldProMsg=$(formatProMsg "$proInsert")
	
	#获取新文件数据库插入语句
	logger "获取$newSql插入语句"
	insertGloVar=$(awk "/$pattern/ {print \$0}" $newSql)

	#协议信息替换
	logger "开始协议信息替换"
	replaceProMsg "$oldProMsg"
	#insertGloVar=$(replaceProMsg "$oldProMsg")
	logger "替换结束！"
	
	#按照创建顺序表调整备份sql文件的删除和插入顺序
	logger "按照$tOrder调整表顺序"
        correctOrder $tOrder $newGenSql $newSql
	logger "调整结束"
	
	#替换新文件协议内容
	logger "替换生成文件$newGenSql插入语句"
	A="`echo | tr '\012' '\001' `"
	insertGloVar=$(echo $insertGloVar | sed 's/\\/\\\\/g')
	sed -i "/${pattern}/s${A}^.*${A}${insertGloVar}${A}" $newGenSql
}

########################################################
# PROCEDURE
########################################################
if [ ! $# -eq 2 ]; then
	echo Usage: With two parameters, one is an old SQL file and the other is a new SQL file >&2
	exit 1
fi
	
# VARIABLES
tOrder="tableOrder.txt"                 #正确表创建顺序
oldSql=$1                               #包含需要覆盖的库的插入protocolbind表语句文件
newSql=$2                               #navicat导出的备份sql语句文件
newGenSql="new_$newSql"
insertGloVar=""				#协议处理较慢

logger "*******************************************************"
logger "开始处理..."
main
logger "处理结束！"
logger "*******************************************************"