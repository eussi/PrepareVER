#!/bin/bash
# program:
#	generate report for ESB ui test
#
# date
#	2018-08-06


awk -f format.awk raw.txt

#awk '
#	BEGIN {
#		"date +%Y-%m-%d" | getline current
#		"date -d yesterday +%Y-%m-%d" | getline yesterday
#
#		yesterdayFile=yesterday "report.txt" #获取昨日数据
#		oldTotalNum=getOld(4)
#		oldExecuted=getOld(6)
#		oldRest=getOld(8)
#		oldAdvice=getOld(10)
#
#		wdith=104
#		headChar="="
#		bodyChar="-"
#		
#		todayFile=current "report.txt"
#		redirect="cat >> " todayFile  #用于关闭输出
#		
#		"cat " ARGV[1] "| wc -l" | getline last  #获取总行数
#
#		print "ESB测试进度(", current, ")：" > todayFile      #打印开头
#		print "" > todayFile
#		close(todayFile)
#	}
#
#	FNR==1 {
#		printf("|  %"15-length($1)"s  |  %"18-length($2)"s  |  %7s  |  %6s  |  %6s  |  %5s  |\n",
#			$1,
#			$2,
#			$3,
#			$4,
#			$5,
#			$6) | redirect
#
#		print printCharLine(wdith, headChar) | redirect
#	}
#
#	FNR>1 {
#		if(match($2,/^F5/)) {   #length函数统计字母和汉字宽度不同
#			n=2
#		}
#		printf("|  %"15-length($1)"s  |  %"18-length($2)+n"s  |  %10s  |  %10s  |  %10s  |  %10s  |\n",
#			$1,
#			$2,
#			$3,
#			$4,
#			$5,
#			$6) | redirect
#		n=0
#
#		if(FNR==last)                      #最后一行处理
#			print printCharLine(wdith, headChar) | redirect
#		else
#			print printCharLine(wdith, bodyChar) | redirect
#
#		totalNum+=$3
#		executed+=$4
#		rest+=$5
#		advice+=$6
#	}
#
#	END {
#		print "统计：" >> todayFile                 #第一个统计表格
#		print printCharLine(wdith, headChar) >> todayFile
#		printf("|  %38s  |  %7s  |  %6s  |  %6s  |  %5s  |\n",   #打印在前面
#			"",
#			"案例数",
#			"已执行数",
#			"未通过数",
#			"建议修改数")  >> todayFile
#		print printCharLine(wdith, headChar) >> todayFile
#		printf("|  %33s  |  %10s  |  %10s  |  %10s  |  %10s  |\n",   #打印在前面
#			"统计总数：",
#			totalNum,
#			executed,
#			rest,
#			advice)  >> todayFile
#		print printCharLine(wdith, bodyChar) >> todayFile
#		printf("|  %33s  |  %10s  |  %10s  |  %10s  |  %10s  |\n", 
#			"今日新增：",
#			totalNum-oldTotalNum,
#			executed-oldExecuted,
#			rest-oldRest,
#			advice-oldAdvice) >> todayFile
#		print printCharLine(wdith, headChar) >> todayFile
#		print "" >> todayFile
#		
#		print "详情：" >> todayFile                    #第二个详情表格
#		print printCharLine(wdith, headChar) >> todayFile
#		close(todayFile)
#		close(redirect)
#
#		print "" >> todayFile                     #结尾
#		print "附件：测试案例" >> todayFile
#		close(todayFile)
#
#		while("cat " todayFile | getline) {     #输出文件到控制台
#			print $0
#		}
#	}
#
#	function printCharLine(num, char) { #打印字符串
#		line=""
#		for(i=0; i<num; i++) {
#			line=line char
#		}
#		return line
#	}
#
#	function getOld(pos) { #获取昨日数据
#		"'"cat "'" yesterdayFile "'" | grep '统计' | awk '{ print $"'" pos "'" }'"'" | getline old          #注意此处引用的字符串中包含空格，这里采用"'" "'"引用
#		return old
#	}
#' raw.txt
#
