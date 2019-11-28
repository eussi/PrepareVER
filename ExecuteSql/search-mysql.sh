#!/bin/bash
mysql_path=/usr/local/mysql
mysql_ip='192.168.198.128'
mysql_port=3306
mysql_user='root'
mysql_pass='root'
mysql_dbname='db_test'
 
serviceIds=601301000101,301301000406,301301003502
beginTime="2019-09-26 00:00:00"
endTime="2019-11-27 00:00:00"
resultFile=./result.`date '+%Y%m%d%H%M%S'`.csv
echo 服务码：$serviceIds
echo 开始时间：$beginTime
echo 结束时间：$endTime

#单位秒
interval=$((1*60*60))

beginTimeStamp=`date -d "$beginTime" +%s`
endTimeStamp=`date -d "$endTime" +%s`
while [ $beginTimeStamp -le $endTimeStamp ]
do
	endRange=$(($beginTimeStamp+$interval))
	if [ $endRange -gt $endTimeStamp ]; then
		endRange=$endTimeStamp
	fi
	echo "查询范围--> [`date -d @$beginTimeStamp '+%Y-%m-%d %H:%M:%S'`,`date -d @$endRange '+%Y-%m-%d %H:%M:%S'`)"
	sqlStr="SELECT\
		  *\
		FROM\
		  (\
		    SELECT\
		      *\
		    FROM
		      t_log t\
		    WHERE\
		      t.TRANSSTAMP1 >= STR_TO_DATE(\
		        '`date -d @$beginTimeStamp '+%Y%m%d %H%M%S'`',\
		        '%Y%m%d %H%i%s'\
		      )\
		    AND t.TRANSSTAMP1 < STR_TO_DATE(\
		      '`date -d @$endRange '+%Y%m%d %H%M%S'`',\
		      '%Y%m%d %H%i%s'\
		    )\
	          ) m\
		WHERE\
		  m.BUSINESSSTATUS = '1'\
		  AND m.SERVICEID IN (\"`echo $serviceIds | sed 's/,/","/g'`\")"
	#echo "${sqlStr}"
	mysql -h${mysql_ip} -P${mysql_port} -u${mysql_user} -p${mysql_pass} ${mysql_dbname} -e " ${sqlStr} " --default-character-set=utf8 |\
		awk -F"\t" 'NR>1{for(i=1;i<=NF;i++){printf("%s,", $i);}printf("\n")}' >> $resultFile
	beginTimeStamp=$(($beginTimeStamp+$interval))
done
echo 查询结束
