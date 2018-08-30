# SimpleScripts
*Record some of the scripts that have been written in work and study*

## PrepareVersion
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
    