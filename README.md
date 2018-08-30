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
	- generate_poweroff.bat
	&#8194;&#8194;Create the shutdown script and generate shortcuts
2. showDesktop
	- showDesktop.scf
	&#8194;&#8194;Run scf, back to desktop
	- generate_showDesktop.bat
	&#8194;&#8194;Create back to desktop scripts and generate shortcuts
3. getAdmin
	- getAdminExecute.bat
	&#8194;&#8194;Get administrator privileges to execute commands
4. replaceHosts
	- replaceHosts.bat
	&#8194;&#8194;Replace the hosts file in the Windows system with the hosts file under this directory
### Notice:
- The script file is encoded using the GBK code
