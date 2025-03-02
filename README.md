# luasocket

A **luasocket** module that works on Windows with lua 5.3 and 5.4 (select the appropriate package in releases)

So far, so good, but when you work under *Windows* it becomes really difficult to get the binaries for this *luasocket* module, as it is **C** based:
- I need the module under *Windows*
- I need it in **Win32** and also **x64** release
- I have **Visual Studio 2017 Community Edition**

I searched and searched, stumbled on [LuaRocks - The Lua package manager](https://luarocks.org/), but never made it to correctly get this module, in the right release, compiled with **Visual Studio**...

## A building solution of mine

So I patched together all the information I managed to get accross the net and I created this procedure.
After many tries with **luarocks**, I realized that the sources of the *luasocket* module where correctly downloaded, but not built at all.

- with **7-zip**, unzip of the file "luasocket-3.0rc1-2.src.rock", precisely, the path "luasocket-3.0rc1-2.src.rock\v3.0-rc1.zip\luasocket-3.0-rc1\"
- copy of "Lua53.props" to "Lua.props"
- update of the paths in the projects to match the correct options for **Visual Studio 2017**
- the type lua library linked with the **luasocket** module must be configured in the "Lua.props" file
```xml
  <PropertyGroup Label="UserMacros">
...
	  <!-- For dynamic or static lua library linking -->
	  <!-- Uncomment one of those 2 lines -->
    <!-- <LUALIB>lua53.lib</LUALIB> -->
    <LUALIB>lua53-static.lib</LUALIB>
  </PropertyGroup>
```
- you can choose to make it (personaly I prefer static, as it avoids the hassle of managing the lua libraries path):
  - *dynamic*, and in this case, the "lua53.dll" must be findable somewhere in the `PATH` of the application using the "luasocket" module
  - *static*, and then the "luasocket" module is self sufficient, no other DLLs are needed
- the build structure has been re-arranged to include the build target architecture in the build path, with **Win32** or **x64** possibilities
- the "lua" binaries and includes paths must be configured correctly in "Lua.props", for example here, with a relative path:
```xml
  <PropertyGroup Label="UserMacros">
    <LUA_PATH>..\..\lua\sources\lua53\</LUA_PATH>
...
  </PropertyGroup>
```
- finally, open "luasocket.sln" solution in "Visual Studio 2017"
- choose the type of build (I suggest "Release") and the desired architecture (among "Win32" or "x64")
- rebuild the solution.
The binaries and lua scripts for the "luasocket" module are available under either:
luasocket\Release\Win32
or
luasocket\Release\x64

### Building with only VS 2022 Development kit

As times are changing, I switched from the good, but oversized, Visual Studio to the _lightweight_ and versatile **VS Code**.  
This switch implies to build C++ applications without the ease of Visual Studio: enters `MsBuild`.  
You need to install the C++ extension for VS Code, with the Software Development kit corresponding, here for `Visual Studio 2022`.

The needed modifications in the projects `.vcxproj` files are following:
- modify the `WindowsTargetPlatformVersion` to something less constraining (one occurence)
```xml
    <Keyword>Win32Proj</Keyword>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
```
- set the `PlatformToolset` to the matching Development kit (several occurences)
```xml
    <PlatformToolset>v143</PlatformToolset>
```

The build is done with the following command, by passing the additional arguments for the Configuration and the Target:
- in a console, start the matching development environment (among `Win32` or `x64`)
```batch
"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars32.bat"
REM OR
"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"

msbuild -version
```
- launch the build of the projects
```batch
MSBuild luasocket.sln /property:Configuration=Release /property:Platform=Win32
REM OR
MSBuild luasocket.sln /property:Configuration=Release /property:Platform=x64
```

A script does this in a shorter way:
```batch
Build-luasocket.cmd Win32
REM OR
Build-luasocket.cmd x64
```

The binaries are available under: `.\Release\Win32` or `.\Release\x64`


## Modifications made to original luasocket

The original "luasocket" module code didn't build out of the box in "Visual Studio 2017", I had to make several modifications:
- for both projects "socket" and "mime", in their "Properties"
  - tab "C/C++", "General"
  - modify "$(LUAINC_PATH)" to "$(LUA_PATH)$(Platform)\include" in "Additional Include Directories"
  - tab "C/C++", "Command Line"
  - add "/FS" in "Additional Options"
  - tab "Linker", "General"
  - modify "$(OutDir)$(TargetName).dll" to "$(Configuration)\$(Platform)\$(ProjectName)\$(TargetName).dll" in "Output File"
  - modify "$(LUALIB_PATH)" to "$(LUA_PATH)$(Platform)\lib" in "Additional Library Directories"
- for all the ".lua" files present in the directories "cdir" and "ldir" of each project
- right clic on "Properties", for the "cdir"
  - tab "Custom Build Tool", "General"
  - modify "Command Line" to:
```batch
copy %(FullPath) $(Configuration)\$(Platform)\
```
  - modify "Outputs" to "$(Configuration)\$(Platform)\%(Filename)%(Extension)"
- right clic on "Properties", for the "ldir"
  - tab "Custom Build Tool", "General"
  - modify "Command Line" to:
```batch
copy %(FullPath) $(Configuration)\$(Platform)\$(ProjectName)\
```
  - modify "Outputs" to "$(Configuration)\$(Platform)\$(ProjectName)\%(Filename)%(Extension)"


The **C** source code of the "luasocket" module was also not **lua 5.3 ready**, I did following modifications to ensure lua 5.3 compatibility:
- added this piece of code at the beginning of those 2 source files "luasocket.c" and "mime.c"
```c
/*=========================================================================*\
* ARi - Needed for lua 5.3 compatibility
\*=========================================================================*/
#ifndef luaL_checkint
#define luaL_checkint(L, n) ((int)luaL_checkinteger(L,n))
#endif
```

## Correction of the `receive` error after lua 5.4.3

From lua 5.4.3 on there is an error in the calls to the `receive` method:
```
lua54.exe: exclient.lua:10: bad argument #1 to 'receive' (string expected, got light userdata)
stack traceback:
        [C]: in method 'receive'
        exclient.lua:10: in main chunk
        [C]: in ?
```

A correction/patch has been provided in the official `luasocket` [GitHub - lunarmodules/luasocket: Network support for the Lua language](https://github.com/lunarmodules/luasocket)  
The complete set of sources in `src` has been refreshed with the content of `luasocket-3.1.0-1.src.rock\luasocket\src\` in the rockspec of release **3.1.0**, downloaded from `luasocket-3.1.0-1.src.rock`

## Basic tests with TCP connection

I wrote a basic script to test a simple message over a TCP connection. There are plenty of scripts to furtherly test some more commplicated functions, 
for instance in [luasocket/samples at master · lunarmodules/luasocket · GitHub](https://github.com/lunarmodules/luasocket/tree/master/samples)

Once you have built `lua54.exe` and `luasocket`, proceed following:
- copy the script `tcpsample.lua` to the luasocket directory: `luasocket\Release\Win32` or `luasocket\Release\x64`
- open 2 consoles on this directory, one for the listener and the second for the client (sends a message)
- in the listener console, launch:
```batch
..\..\..\lua54\x64\bin\lua54.exe -e "require('tcpsample').listen('127.0.0.1', 6060)"
```
- in the client console, launch:
```batch
..\..\..\lua54\x64\bin\lua54.exe -e "require('tcpsample').sample('127.0.0.1', 6060, 'Hello guys')"
```
- check that the message is correctly received in the listener console, it should look like this
```
TCP listen on: 127.0.0.1:6060    (Ctrl+C to quit...)
Hello guys
-- debug: closed
```
