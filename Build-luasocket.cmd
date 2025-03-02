@ECHO OFF

REM Set build target
SET TARGET=Win32
IF "%1"=="x64" SET TARGET=x64
REM Set the lua engine version (not dotted)
SET LUA=54
IF NOT "%2EMPTY"=="EMPTY" SET LUA=%2

SET DIR_LUA=..\lua%LUA%

ECHO Build luasocket for Windows ?
ECHO - lua version is %LUA%
ECHO - target platform is %TARGET%
ECHO Make sure to have lua incudes and binaries in: %DIR_LUA%\%TARGET%
PAUSE

REM Set build environment according to build target
IF "%TARGET%"=="Win32" (
	CALL "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars32.bat"
	
	MSBuild luasocket.sln /property:Configuration=Release /property:Platform=Win32
) ELSE (
	CALL "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
	
	MSBuild luasocket.sln /property:Configuration=Release /property:Platform=x64
)

PAUSE
