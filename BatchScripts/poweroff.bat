::Program£º
::	Timed shutdown script
::Author:
::	wangxueming
::Date:
::	2018-05-07 First Release
:: "::" annotation
:: "@echo off" only show results, no command line is displayed
:: "echo off" only show results, no command line is displayed, but this command line is included
@echo off
:: "mode con cols=56 lines=10" set windows size
mode con lines=25
title Timed shutdown
:: color fb f=front color b back color
:: 0 ºÚÉ« 1 À¶É« 2 ÂÌÉ« 3 ºìÉ« 5 ×ÏÉ«
:: 6 »ÆÉ« 7 °×É« 8 »ÒÉ« 9 µ­À¶É«
:: A µ­ÂÌÉ« B µ­Ç³ÂÌÉ« C µ­ºìÉ«
:: D µ­×ÏÉ« E µ­»ÆÉ« F ÁÁ°×É«
color f0
:: start delayed expansion to use variable nesting eg. ! %%!
setlocal enabledelayedexpansion
cls
set "timeGoal= shutdown"

:: "echo." equals press enter
echo.
echo.
echo ****************************************************************
echo.*                                                              *
echo *                        TIMED SHUTDOWN                        *
echo.*                                                              *
echo *        Timed shutdown, input time of 24-hour system          *
echo.*                                                              *
echo *         Canncel scheduled shutdown, press N or n             *
echo *            Shutdown immediately, press Enter                 *
echo.*                                                              *
echo ****************************************************************
echo.

set /p "timeGoal= Please enter the shutdown time:"
echo.
if %timeGoal%==N goto cancel
if %timeGoal%==n goto cancel
if %timeGoal%==shutdown goto shutdown

set tmp=%timeGoal%
set /a num = 0
:: Variable substitution " --> space
set "tmp=%tmp:"= %"

::Calculate the number of digits before the colon
:next
if not "%tmp:~0,1%"==":" (
	set /a num+=1
	set "tmp=%tmp:~1%"
	goto next
)

set /a hourNow = %time:~0,2%
set /a minuteNow = %time:~3,2%
set /a secNow = %time:~6,2%

set "hourStr=!timeGoal:~0,%num%!"
set /a num+=1
set "minuteStr=!timeGoal:~%num%,2!"

:rmhourzero
if "%hourStr:~0,1%"=="0" (
	set "hourStr=%hourStr:~1%"
	goto rmhourzero
)
:rmminutezero
if "%minuteStr:~0,1%"=="0" (
	set "minuteStr=%minuteStr:~1%"
	goto rmminutezero
)

set /a hourGoal = hourStr
set /a minuteGoal = minuteStr

set /a isToday = hourGoal - hourNow
if %isToday% lss 0 (
	echo  Tomorrow %timeGoal% shutdown
	echo.
	set /a "isToday += 24"
)
set /a "isToday = isToday*3600+(minuteGoal-minuteNow)*60 - secNow"
shutdown -s -t %isToday%
echo have set %timeGoal% shutdown
goto exit

:cancel
shutdown -a
echo Canceled shutdown plan
goto exit

:shutdown
echo shutdown immdiately after 5 seconds
shutdown -s -t 5
goto exit

:exit
echo .
echo Exit after 3 seconds
choice /t 3 /d y >nul
