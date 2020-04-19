# How to build lua for Windows with Visual Studio 2017

Simple said, I need **lua** and I need it under *Windows*. I need it precisely to be able to debug the *lua* scripted extensions and plugins that I realize under 2 of my favourite editors [SciTE](https://www.scintilla.org/SciTE.html) and [Textadept](https://foicica.com/textadept/).
To achieve this debugging, there are a lot of modules out there, all of them relying on a module called **luasocket**.

So far, so good, but when you work under *Windows* it becomes really difficult to get the binaries for this *luasocket* module, as it is **C** based:
- I need the module under *Windows*
- I need it in **Win32** and also **x64** release
- I have **Visual Studio 2017 Community Edition**

I searched and searched, stumbled on [LuaRocks - The Lua package manager](https://luarocks.org/), but never made it to correctly get this module, in the right release, compiled with **Visual Studio**...

So first step, is to build **lua**. I found this site: 
[How to compile Lua 5.3.5 for Windows | The curse of Dennis D. Spreen](https://blog.spreendigital.de/2019/06/25/how-to-compile-lua-5-3-5-for-windows/)

It works correctly, and was a solid base for my needs. I added a build script, that enable to build on Windows, with **Visual Studio 2017** installed. The script produces the binaries for **lua** under those sub-directories:
