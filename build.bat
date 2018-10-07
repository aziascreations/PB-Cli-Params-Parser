@echo off
::setlocal enableextensions enabledelayedexpansion
setlocal enabledelayedexpansion

set COMMENT_COMMON=comment-common.txt
set COMMENT_LIB=comment-lib.txt
set COMMENT_DOC=comment-doc.txt
set "PATH=%PATH%;C:\Program Files\PureBasic\Purebasic 5.62 x64\Compilers\"
set "PATH=%PATH%;C:\Program Files\WinRAR\"

:: the "%PATH%:exe" fixes an issue with where in which it cannot find executables in the modified PATH
where /q "%PATH%:pbcompiler"
if %ERRORLEVEL% neq 0 (
	echo ERROR: Unable to find pbcompiler.exe in modified PATH !
	goto end
)
:: TODO: Check if winrar exists or 7zip
where /q "%PATH%:rar"
if %ERRORLEVEL% neq 0 (
	echo ERROR: Unable to find rar.exe in modified PATH !
	goto end
)
where /q "%PATH%:grep"
if %ERRORLEVEL% neq 0 (
	echo ERROR: Unable to find grep in modified PATH !
	goto end
)

pushd %~dp0


echo --==## Starting Build Process... ##==--

for /f %%i in ('git rev-parse HEAD') do set COMMIT_HASH=%%i
for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set COMMIT_BRANCH=%%i
for /f %%i in ('grep -Eo "([0-9]+\.){2}[0-9]+" cli-args.pbi') do set LIB_VERSION=%%i

echo Current commit: %COMMIT_HASH% @ %COMMIT_BRANCH%
echo Current version: %LIB_VERSION%
echo.


echo --==## Cleaning Build Folder... ##==--
rmdir /S /Q Build
mkdir .\Build\Temp
mkdir .\Build\Temp\Examples
mkdir .\Build\Temp\Includes
mkdir .\Build\Release
echo.


echo --==## Preparing Files for Archiving... ##==--
copy .\readme.md .\Build\Temp\readme.md
copy .\LICENSE .\Build\Temp\LICENSE
copy .\*.pbi .\Build\Temp\Includes\
copy .\Examples\*.pb .\Build\Temp\Examples\
move .\Build\Temp\Includes\cli-args.pbi .\Build\Temp\Includes\cli-params-parser.pbi
pbcompiler /PREPROCESS .\Build\Temp\Includes\cli-params-parser.min.pbi .\Build\Temp\Includes\cli-params-parser.pbi
:: TODO: Compile documentation CHM !!!
echo.


cd .\Build\Temp\

:: TODO: Add archiving date !
echo --==## Creating Archives... ##==--
:: Comment part:
echo.>> %COMMENT_COMMON%
echo Commit Hash:>> %COMMENT_COMMON%
echo     %COMMIT_HASH% @ %COMMIT_BRANCH%>> %COMMENT_COMMON%
echo.>> %COMMENT_COMMON%
echo Links:>> %COMMENT_COMMON%
echo     Github: github.com/aziascreations/PB-Cli-Params-Parser>> %COMMENT_COMMON%
echo.>> %COMMENT_COMMON%
echo License:>> %COMMENT_COMMON%
echo     Apache V2>> %COMMENT_COMMON%

echo PureBasic Cli Parameters Parser v%LIB_VERSION%>>%COMMENT_LIB%
type %COMMENT_COMMON% >> %COMMENT_LIB%
echo PureBasic Cli Parameters Parser v%LIB_VERSION% - Documentation>>%COMMENT_DOC%
type %COMMENT_COMMON% >> %COMMENT_DOC%

:: Archiving part:
:: TODO: Compress documentation !!!
::rar a -zcomment-lib.txt "..\Release\PB-Cli-Params-Parser_%LIB_VERSION%.zip" .\cli-params-parser.pbi .\cli-params-parser.min.pbi .\readme.md .\LICENSE
rar a -zcomment-lib.txt "..\Release\PB-Cli-Params-Parser-v%LIB_VERSION%.zip" .\Includes\*.pbi .\Examples\*.pb .\LICENSE

echo.

:end
pause
explorer ..\Release\
cd ..\..
rmdir /S /Q .\Build\Temp

popd
endlocal
