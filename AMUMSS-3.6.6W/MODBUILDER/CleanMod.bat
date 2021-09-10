@echo off

:RETRY2
Del /f /q /s "MOD\*.*" 1>NUL 2>NUL
if exist "MOD" (
	rd /s /q "MOD" 2>NUL
	goto :RETRY2
)
mkdir "MOD"
