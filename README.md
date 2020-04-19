# luasocket

A **luasocket** module that works on Windows with lua 5.3

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
