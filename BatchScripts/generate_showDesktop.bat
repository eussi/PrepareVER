::Program：
::	Show Desktop
::Author:
::	wangxueming
::Date:
::	2018-06-13

@echo off
cls
set "batGenePath=%temp%\\"
set "batShorCut=Ctrl+Alt+a"
set "batName=showDesktop"

set "batFile=%batGenePath%_%batName%.scf"
echo %batFile%

::创建显示桌面scf文件
echo [Shell] >%batFile%
echo Command=2 >>%batFile%
echo IconFile=explorer.exe,3 >>%batFile%
echo [Taskbar] >>%batFile%
echo Command=ToggleDesktop >>%batFile%

::创建桌面快捷方式
set "vbsName=showDesktop.vbs"
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
echo Link.Hotkey = "Ctrl+Alt+o" >>%vbsFile%
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