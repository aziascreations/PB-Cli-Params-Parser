@echo off
setlocal enableextensions enabledelayedexpansion

set PATH=%PATH%;"C:\Program Files\PureBasic\Purebasic 5.62 x64\Compilers\"
set PATH=%PATH%;"C:\Program Files\WinRAR\"
pushd %~dp0

:: TODO: Add examples in archives and all.

echo --==## Starting Build Process... ##==--

for /f %%i in ('git rev-parse HEAD') do set COMMIT_HASH=%%i
for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set COMMIT_BRANCH=%%i
:: TODO: grep the version number!
set LIB_VERSION=0.0.3

echo Current commit: %COMMIT_HASH% @ %COMMIT_BRANCH%
echo Current version: %LIB_VERSION%
echo.


echo --==## Cleaning Build Folder... ##==--
rmdir /S /Q Build
mkdir .\Build\Temp
mkdir .\Build\Release
echo.


echo --==## Preparing Files for Archiving... ##==--
copy .\readme.md .\Build\Temp\readme.md
copy .\LICENSE .\Build\Temp\LICENSE
copy .\cli-args.pbi .\Build\Temp\cli-params-parser.pbi
pbcompiler /PREPROCESS .\Build\Temp\cli-params-parser.min.pbi .\Build\Temp\cli-params-parser.pbi
:: TODO: Compile documentation CHM !!!
echo.


cd .\Build\Temp\


echo --==## Creating Archives... ##==--
:: Comment part:
echo.>> comment-common.txt
echo Commit Hash:>> comment-common.txt
echo     %COMMIT_HASH% @ %COMMIT_BRANCH%>> comment-common.txt
echo.>> comment-common.txt
echo Links:>> comment-common.txt
echo     Github: github.com/aziascreations/PB-Cli-Params-Parser>> comment-common.txt
echo.>> comment-common.txt
echo License:>> comment-common.txt
echo     Apache V2>> comment-common.txt

echo PureBasic Cli Parameters Parser v%LIB_VERSION%>>comment-lib.txt
type comment-common.txt >> comment-lib.txt
echo PureBasic Cli Parameters Parser v%LIB_VERSION% - Documentation>>comment-doc.txt
type comment-common.txt >> comment-doc.txt

:: Archiving part:
:: TODO: Compress documentation !!!
::rar a -zcomment-lib.txt "..\Release\PB-Cli-Params-Parser_%LIB_VERSION%.zip" .\cli-params-parser.pbi .\cli-params-parser.min.pbi .\readme.md .\LICENSE
rar a -zcomment-lib.txt "..\Release\PB-Cli-Params-Parser_%LIB_VERSION%.zip" .\*.pbi .\LICENSE

echo.

::pause2 -w 2>nul
pause

up 2
popd

endlocal
