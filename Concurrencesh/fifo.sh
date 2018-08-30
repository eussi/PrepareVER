#!/bin/bash

Njob=15 #任务总数
Nproc=5 #最大并发逬程数

mkfifo ./fifo.$$ && exec 777<>./fifo.$$ && rm -f ./fifo.$$ #通过文件插述符777访问fifo文件

for((i=0; i<$Nproc; i++)) #向fifo文件先填充等于Nproc值的行数
do
	echo "init time add $i" >&777
done

for((i=0; i<$Njob; i++))
do
	read -u777 #从fifo文件读一行，放在这里顺序执行
	{
		#read -u777    #从fifo文件读一行
		echo "progress $i is sleeping for 3 seconds..."
		sleep 3
		echo "real time add $(($i+$Nproc))" >&777 #sleep完成后，向fifo文件重新写入一行
	} &
done

wait

echo -e "time-consuming:$SECONDS seconds"

exec 777>&-  #关闭文件描述符的写
exec 777<&-  #关闭文件描述符的读
