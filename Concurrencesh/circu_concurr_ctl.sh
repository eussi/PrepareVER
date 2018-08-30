#!/bin/bash
Njob=15
sep=5 # 每次执行任务限制数
for ((i=0; i<$(($Njob/$sep)); i++))
do
	for((j=0;j<$sep;j++))
	do
          echo  "progress $((i*$sep+j)) is sleeping for 3 seconds..."
          sleep  3 &       #循环内容放到后台执行
	done
	wait
done
echo -e "time-consuming: $SECONDS    seconds"    #显示脚本执行耗时

#for后面的wait命令以循环中最慢的进程结束为结束（水桶效应）。如果嵌套循环中有某一个进程执行过程较慢，那么整体这一轮内嵌循环的执行时间就等于这个“慢”进程的执行时间，整体下来脚本的执行效率还是受到影响的
