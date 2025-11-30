@echo off
setlocal enabledelayedexpansion

:: 设置统一备份根目录
set BACKUP_ROOT=D:\Backup

:: 获取当前日期（格式：YYYYMMDD）
for /f "tokens=1-4 delims=/.- " %%a in ('date /t') do (
    set d1=%%a
    set d2=%%b
    set d3=%%c
    set d4=%%d
)

if "%d1:~-4%" GEQ "2000" (
    set DATE=%d1:~-4%%d2:~-2%%d3:~-2%
) else if "%d3:~-4%" GEQ "2000" (
    set DATE=%d3:~-4%%d1:~-2%%d2:~-2%
) else if "%d4:~-4%" GEQ "2000" (
    set DATE=%d4:~-4%%d2:~-2%%d3:~-2%
)

if not defined DATE (
    set DATE=%d3:~-4%%d1:~-2%%d2:~-2%
)

echo  当前备份日期为：%DATE%

:: === Chrome 备份（以 User Data 为根目录，排除所有缓存） ===
set CHROME_SRC=C:\Users\Administrator\AppData\Local\Google\Chrome\User Data
set CHROME_DST=%BACKUP_ROOT%\Chrome\Backup_%DATE%\User Data
if not exist "%CHROME_DST%" mkdir "%CHROME_DST%"

:: Chrome 缓存排除列表（使用 call 技巧）
set CHROME_EXCLUDE=/XD "Cache" "Code Cache" "GPUCache"  "DawnCache" "DawnGraphiteCache" "DawnWebGPUCache"  "component_crx_cache" "extensions_crx_cache" "ShaderCache" "GrShaderCache" "GraphiteDawnCache" "Crashpad" "Safe Browsing" "SSLErrorAssistant" "SODA" "screen_ai" "segmentation_platform"
echo  正在备份 Chrome（排除以下缓存目录）：
echo  %CHROME_EXCLUDE%
robocopy "%CHROME_SRC%" "%CHROME_DST%" /E /COPYALL /R:0 /W:0 %CHROME_EXCLUDE%

:: === Termius 备份（robocopy版本） ===
set TERMIUS_SRC=C:\Users\Administrator\AppData\Roaming\Termius
set TERMIUS_DST=%BACKUP_ROOT%\Termius\Backup_%DATE%
if not exist "%TERMIUS_DST%" mkdir "%TERMIUS_DST%"

robocopy "%TERMIUS_SRC%" "%TERMIUS_DST%" /E /COPYALL /R:0 /W:0

echo  Termius 数据已备份完成！

echo  Chrome 和 Termius 数据已全部备份完成！
pause


