# AMUMSS
A tool to mod No Man's Sky (NMS) using lua scripts

In other words: a tool that uses .lua scripts to create .pak mod files
  >>> .lua scripts go into the ModScript folder (created after you run BULDMOD.bat)
  >>> .pak files go into NMS PCBANKS\MODS (a folder you create to use mods with NMS)

FOR HELP WITH INSTALLATION:
  Refer to [https://discord.gg/HFjnmnwe67](https://www.nexusmods.com/nomanssky/mods/2626)
  
IMPORTANT NOTES:
  AMUMSS uses MBINCompiler.exe
  
  STARTING July 17th, 2023: NEWER MBINCompiler.exe versions REQUIRE '.NET 6 x64 Desktop Runtime' latest version to run:
  It can be found at https://dotnet.microsoft.com/download/dotnet/6.0/runtime
  (.NET 7/8/... are NOT backward compatible with .NET 6) 
  
  OLDER MBINCompiler.exe versions still REQUIRE '.NET 5 x64 Desktop Runtime' latest version to run:
  It can be found at https://dotnet.microsoft.com/download/dotnet/5.0/runtime
  (.NET 6/7/8/... are NOT backward compatible with .NET 5) 

For now, this is a repository of AMUMSS versions going forward.

SEE the RELEASES for latest version
> This version will auto-update with the execution of BUILDMOD.bat.
> It may take one or many re-start of BUILMOD.bat to bring it to the latest version.
  No worry, it is fast (only depends on your internet speed)

DOWNLOAD and INSTALLATION:
	*** Follow installation instructions found in file at https://www.nexusmods.com/nomanssky/mods/2626
	
> DOWNLOAD COMPLETE VERSION
    * COMPLETE VERSION available as a .7z release at:
        https://github.com/HolterPhylo/AMUMSS/releases (you need the 'Latest' release: AMUMSS.7z, +/- 145MB)
    * 'Unblock' the downloaded file in 'Properties' in the windows explorer
    * you can unzip it with 7zip at: https://www.7-zip.org/download.html
    
    * IMPORTANT Note:
		+ Your anti-virus may detect some component of AMUMSS and block/quarantine it.
		  Be assure it is not a virus but its behavior may be interpreted as such by some anti-virus.
		+ Please make sure to create an 'exception' in your anti-virus BEFORE executing anything in AMUMSS main folder.
		+ Also a reboot may be required as some anti-virus do not correctly register the exception when it is created.

> INSTALLATION
    * Complete the step in the DOWNLOAD COMPLETE VERSION section above before continuing
	
    * No accented characters in the path of AMUMSS folder
    * Always de-compress/un-zip in a new folder on any drive like X:\AMUMSS (OR in the previous folder)
      xxxxx NEVER in any system folder (Note: the Desktop, Downloads, Documents are system folders) xxxxx

        * If de-compressed/extracted in the previous folder, AMUMSS will preserve everything in user folders
          except changes made to AMUMSS files in AMUMSS main, ModScriptCollection and MODBUILDER folders

        * If de-compressed/extracted in a new folder, you can copy/paste these folders from the previous version of AMUMSS
          if you would like to preserve previous work and information...
                + 'Builds'
                + 'ModScript'
                + 'ModExtraFilesToInclude'
                + 'NMSPE_Output'
                + 'SavedSections'
                + 'UNPACKED_DECOMPILED_PAKs'
                + any other files in AMUMSS main not updated by the unzip file

        * You can delete the compressed file from AMUMSS main folder when done

	* EXECUTE BUILDMOD.bat ONCE or more until no more updates are offered
			+ Please execute BUILDMOD.bat once to re-create all user folders (when they do not exist)
            + it will auto-download\update MBINCompiler.exe and libMBIN.dll


> QUESTIONS
        * Questions are better asked in NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:

                    https://discord.gg/HFjnmnwe67

        We have channel #amumss-lua dedicated to AMUMSS/NMSPE with helpful modders and Wbertro#8596 (aka TheBossBoy)

Wbertro
