#!/bin/bash
Njob=15
for((i=0;i<$Njob;i++))
do
	echo "progress $i is sleeping for 3 seconds..."
	sleep 3 &
done

wait #等待循环结束再执行wait后面的内容
echo -e "time-consuming: $SECONDS    seconds"    #显示脚本执行耗时

#这种方式从功能上实现了使用shell脚本并行执行多个循环进程，但是它缺乏控制机制
#一个应对办法是在for循环里面再嵌套一层循环，这样同一时间，系统最多只会执行内嵌循环限制值的个数的进程。不过还有一个问题，for后面的wait命令以循环中最慢的进程结束为结束（水桶效应）
