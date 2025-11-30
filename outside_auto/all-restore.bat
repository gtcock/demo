@echo off
setlocal enabledelayedexpansion

:: === 配置恢复目标和备份根目录 ===
set CHROME_TARGET=C:\Users\Administrator\AppData\Local\Google\Chrome
set CHROME_BACKUP=D:\Chrome

set TERMIUS_TARGET=C:\Users\Administrator\AppData\Roaming\Termius
set TERMIUS_BACKUP=D:\Termius

:: === 函数：查找最新备份目录 ===
set latestChromeDate=0
for /d %%D in ("%CHROME_BACKUP%\Backup_*") do (
    set folder=%%~nxD
    set dateStr=!folder:Backup_=!
    if !dateStr! GTR !latestChromeDate! (
        set latestChromeDate=!dateStr!
        set latestChromeFolder=%%D
    )
)

set latestTermiusDate=0
for /d %%D in ("%TERMIUS_BACKUP%\Backup_*") do (
    set folder=%%~nxD
    set dateStr=!folder:Backup_=!
    if !dateStr! GTR !latestTermiusDate! (
        set latestTermiusDate=!dateStr!
        set latestTermiusFolder=%%D
    )
)

:: === 检查备份是否存在 ===
if "%latestChromeFolder%"=="" (
    echo ? 未找到 Chrome 备份目录，请确认路径：%CHROME_BACKUP%
    pause
    exit /b
)
if "%latestTermiusFolder%"=="" (
    echo ? 未找到 Termius 备份目录，请确认路径：%TERMIUS_BACKUP%
    pause
    exit /b
)

:: === 提示用户确认 ===
echo ? 最新 Chrome 备份目录：%latestChromeFolder%
echo ? 最新 Termius 备份目录：%latestTermiusFolder%
echo 即将恢复到：
echo   Chrome → %CHROME_TARGET%
echo   Termius → %TERMIUS_TARGET%
echo 请确保 Chrome 和 Termius 已关闭，然后按任意键继续...
pause

:: === 执行恢复 ===
echo ?? 正在恢复 Chrome 数据...
xcopy "%latestChromeFolder%" "%CHROME_TARGET%" /E /H /C /I /Y

echo ?? 正在恢复 Termius 数据...
xcopy "%latestTermiusFolder%" "%TERMIUS_TARGET%" /E /H /C /I /Y

echo ? 恢复完成！Chrome 和 Termius 数据已从最新备份还原。
pause
