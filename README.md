# SimpleScripts
*Record some of the scripts that have been written in work and study*

## PrepareVersion
### type:
Shell scripts
### Function:
Extract the files in the list by configuring the file list in the configuration file and make it a Tar packet
### Usage:
1. The configuration file  
    - configs/configs.properties：  
    &#8194;&#8194;Configure the generated tar package name and the deployment directory of the ESB
    - fileList.txt：  
    &#8194;&#8194;Configure the files extracted directly by path
    - tranCode.txt：  
    &#8194;&#8194;Configure what need to be extracted according to the transaction code, channel and service
2. run the program
    - Put the program on the server on which the file was extracted
    - Enter script directory, Execute the command:  
    &#8194;&#8194;'sh start.sh' or './start.sh'
### Notice:
- Pay attention to the configuration profile before using it

## BatchScripts
### type:
Batch scripts
### Usage:
1. poweroff
	- poweroff.bat:  
	&#8194;&#8194;Run bat, timing shut down or shut down directly
	- generate_poweroff.bat:  
	&#8194;&#8194;Create the shutdown script and generate shortcuts
2. showDesktop
	- showDesktop.scf:  
	&#8194;&#8194;Run scf, back to desktop
	- generate_showDesktop.bat:  
	&#8194;&#8194;Create back to desktop scripts and generate shortcuts
3. getAdmin
	- getAdminExecute.bat:  
	&#8194;&#8194;Get administrator privileges to execute commands
4. replaceHosts
	- replaceHosts.bat:  
	&#8194;&#8194;Replace the hosts file in the Windows system with the hosts file under this directory
### Notice:
- The script file is encoded using the GBK code

## Concurrencesh
### type:
Shell scripts
### Function:
Multithreading runs tasks in the shell
### Usage:
1. circulation.sh:  
	&#8194;&#8194;Sequential execution
2. circu_concurr.sh:  
	&#8194;&#8194;Parallel execution, but lack of control
3. circu_concurr_ctl.sh:  
	&#8194;&#8194;Parallel execution, but a slow process can affect efficiency
4. queue.sh:  
	&#8194;&#8194;Control parallel execution by queue
5. fifo.sh:  
	&#8194;&#8194;Control parallel execution by named pipe

## StatisticsResult
### type:
Shell scripts
### Function:
The total number of completed today is compared with the number of completed yesterday, showing the statistical results, the comparison results and the details
### Usage:
1. raw.txt:    
	&#8194;&#8194;Completion status
2. xxxx-xx-xxreport.txt:  
	&#8194;&#8194;Yesterday's statistics
3. report.sh:  
	&#8194;&#8194;Statistic result today, generate a file, name is xxxx-xx-xxreport.txt
### Notice:
- xxxx-xx-xxreport.txt, this file's date is yesterday, it contains yesterday's statistics

## CorrectSql
### type:
Shell scripts
### Function:
Adjust the order in which the database export builds tables, and update the protocol information in the database to be overwritten to the adjusted file
### Usage:
1. tableOrder.txt:    
	&#8194;&#8194;table order
2. thisisPd.txt:  
	&#8194;&#8194;Encrypted test data by TrueCrypt
3. correctSql.sh:  
	&#8194;&#8194;arg1 is oldfile, arg2 is adjustfile, run this file, adjust order and update protocol information
4. correctSql2.sh:  
	&#8194;&#8194;arg1 is oldfile, arg2 is adjustfile, run this file, adjust order and update protocol information, correctSql.sh has some problems, eg: too long args, deal slowly
### Notice:
- password is clearly

## ExecuteSql
### type:
Shell scripts
### Function:
Split a large time range into many small time ranges to execute SQL statements
### Usage:
1. search-mysql.sh:  
	&#8194;&#8194;just run it
### Notice:
- No arguments are used in the script, and some variables in the script need to be modified before execution

## AutoDeployApp
### type:
Shell scripts
### Function:
Automatic deployment application
### Usage:
1. installAgent.sh:  
	&#8194;&#8194;Install distributed Agent,just run it
### Notice:
- No arguments are used in the script, and some variables in the script need to be modified before execution