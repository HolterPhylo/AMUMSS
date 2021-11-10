@echo on
for /r %%a in (*.pak) do ..\..\psarc.exe extract "%%a"
for /r %%a in (*.MBIN) do ..\..\MBINCompiler.exe "%%a"
pause 



