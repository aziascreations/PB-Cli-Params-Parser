XIncludeFile "../cli-args.pbi"

Root = CreateRootVerb("[Program' desc.]")

RegisterArgument(Root, 'a', "", "Change only the access time", 0)
RegisterArgument(Root, 'c', "no-create", "Do not create any files", 0)
RegisterArgument(Root, 'C', "", "Change only the creation time", 0)
RegisterArgument(Root, 'm', "", "Change only the modification time", 0)
RegisterArgument(Root, 'n', "", "Only create files, don't change any time", 0)
RegisterArgument(Root, 'v', "verbose", "Extra verbose With errors And warnings", 0)
RegisterArgument(Root, 'h', "help", "Display this help and exit", 0)
RegisterArgument(Root, 0, "version", "Output version information and exit", 0)

;ParseArguments(Root)

If IsArgumentUsed(Root, "h")
	If OpenConsole()
		PrintN("[help text]")
		
		CompilerIf #PB_Compiler_Debugger
			PrintN(#CRLF$ + "Press any key...")
			Input()
		CompilerEndIf
	Else
		Debug "Couldn't open the console !"
	EndIf
	
	End 0
EndIf



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 13
; Folding = -
; EnableXP