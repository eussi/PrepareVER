::Program：
::	Timed  shutdown batch processing, placed in the windows system boot position, generate a batch file, and generate shortcuts, set shortcuts
::Author:
::	wangxueming
::Date:
::	2018-06-10

@echo off
cls
set "batGenePath=%temp%\\"
set "batShorCut=Ctrl+Alt+z"
set "batName=poweroff"

set "batFile=%batGenePath%_%batName%.bat"
echo %batFile%

::创建关机批处理文件
echo @echo off >%batFile%
echo mode con lines=25 >>%batFile%
echo title Generate timed shutdown >>%batFile%
echo color f0 >>%batFile%
echo setlocal enabledelayedexpansion >>%batFile%
echo cls >>%batFile%
echo set "timeGoal= shutdown" >>%batFile%
echo echo. >>%batFile%
echo echo. >>%batFile%
echo echo **************************************************************** >>%batFile%
echo echo.*                                                              * >>%batFile%
echo echo *                        TIMED SHUTDOWN                        * >>%batFile%
echo echo.*                                                              * >>%batFile%
echo echo *        Timed shutdown, input time of 24-hour system          * >>%batFile%
echo echo.*                                                              * >>%batFile%
echo echo *         Canncel scheduled shutdown, press N or n             * >>%batFile%
echo echo *            Shutdown immediately, press Enter                 * >>%batFile%
echo echo.*                                                              * >>%batFile%
echo echo **************************************************************** >>%batFile%
echo echo. >>%batFile%
echo set /p "timeGoal= Please enter the shutdown time:" >>%batFile%
echo echo. >>%batFile%
echo if %%timeGoal%%==N goto cancel >>%batFile%
echo if %%timeGoal%%==n goto cancel >>%batFile%
echo if %%timeGoal%%==shutdown goto shutdown >>%batFile%
echo set tmp=%%timeGoal%% >>%batFile%
echo set /a num = 0 >>%batFile%
echo set ^"tmp=%%tmp:^"= %%^" >>%batFile%
echo :next >>%batFile%
echo if not "%%tmp:~0,1%%"==":" ( >>%batFile%
echo 	set /a num+=1 >>%batFile%
echo 	set "tmp=%%tmp:~1%%" >>%batFile%
echo 	goto next >>%batFile%
echo ) >>%batFile%
echo set /a hourNow = %%time:~0,2%% >>%batFile%
echo set /a minuteNow = %%time:~3,2%% >>%batFile%
echo set /a secNow = %%time:~6,2%% >>%batFile%
echo set "hourStr=!timeGoal:~0,%%num%%!" >>%batFile%
echo set /a num+=1 >>%batFile%
echo set "minuteStr=!timeGoal:~%%num%%,2!" >>%batFile%
echo :rmhourzero >>%batFile%
echo if "%%hourStr:~0,1%%"=="0" ( >>%batFile%
echo 	set "hourStr=%%hourStr:~1%%" >>%batFile%
echo 	goto rmhourzero >>%batFile%
echo ) >>%batFile%
echo :rmminutezero >>%batFile%
echo if "%%minuteStr:~0,1%%"=="0" ( >>%batFile%
echo 	set "minuteStr=%%minuteStr:~1%%" >>%batFile%
echo 	goto rmminutezero >>%batFile%
echo ) >>%batFile%
echo set /a hourGoal = hourStr >>%batFile%
echo set /a minuteGoal = minuteStr >>%batFile%
echo set /a isToday = hourGoal - hourNow >>%batFile%
echo if %%isToday%% lss 0 ( >>%batFile%
echo 	echo  Tomorrow %%timeGoal%% shutdown >>%batFile%
echo 	echo. >>%batFile%
echo 	set /a "isToday += 24" >>%batFile%
echo ) >>%batFile%
echo set /a "isToday = isToday*3600+(minuteGoal-minuteNow)*60 - secNow" >>%batFile%
echo shutdown -s -t %%isToday%% >>%batFile%
echo echo have set %%timeGoal%% shutdown >>%batFile%
echo goto exit >>%batFile%
echo :cancel >>%batFile%
echo shutdown -a >>%batFile%
echo echo Canceled shutdown plan >>%batFile%
echo goto exit >>%batFile%
echo :shutdown >>%batFile%
echo echo shutdown immdiately after 5 seconds >>%batFile%
echo shutdown -s -t 5 >>%batFile%
echo goto exit >>%batFile%
echo :exit >>%batFile%
echo echo . >>%batFile%
echo echo Exit after 3 seconds >>%batFile%
echo choice /t 3 /d y ^>nul >>%batFile%

::创建桌面快捷方式
set "vbsName=poweroff.vbs"
set "vbsFile=%batGenePath%%vbsName%"
echo thePath = "%batFile%" >%vbsFile%
echo lnkname = "%userprofile%\\Desktop\\%batName%.lnk" >>%vbsFile%
echo WS = "Wscript.Shell" >>%vbsFile%
echo Set Shell = CreateObject(WS) >>%vbsFile%
echo Set Link = Shell.CreateShortcut(lnkname) >>%vbsFile%
::set shortCut
::在内存中变化几次，使得快捷键生效
echo Link.TargetPath = thePath >>%vbsFile%
echo Link.Hotkey = "%batShorCut%" >>%vbsFile%
echo Link.Save >>%vbsFile%
echo Link.Hotkey = "Ctrl+Alt+p" >>%vbsFile%
echo Link.Save >>%vbsFile%
::echo Set fso = CreateObject("Scripting.FileSystemObject") >>%vbsFile%
::echo f = fso.DeleteFile(WScript.ScriptName) >>%vbsFile%
echo WScript.Echo "SUCCESS" >>%vbsFile%

::获取vbs返回码，设置快捷方式隐藏属性
cd %batGenePath%
for /f "delims=" %%i in ('cscript //nologo %vbsName%') do set "returnCode=%%i"
	if %returnCode%==SUCCESS (
		attrib -s +h -r %userprofile%\\Desktop\\%batName%.lnk
	)