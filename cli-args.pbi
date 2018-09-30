; ╔═════════════════════════════════════════════════════════╦════════╗
; ║ Purebasic Utils - Cli-args !!!DEPRECATED!!!             ║ v0.0.1 ║
; ╠═════════════════════════════════════════════════════════╩════════╣
; ║ This module can be used to easily parse launch arguments and     ║
; ║  use them in projects.                                           ║
; ╟──────────────────────────────────────────────────────────────────╢
; ║ Additional infos:                                                ║
; ║  If you want To use "sub-command" like git, you can simply       ║
; ║   use ProgramParameter() once before calling ParseArguments().   ║
; ║  And then you can start registering options depending on the     ║
; ║   "sub-command".                                                 ║
; ║  However, you won't be able to easily change the output of       ║
; ║   PrintHelpText() without having to make one yourself.           ║
; ╟──────────────────────────────────────────────────────────────────╢
; ║ Requirements: PB v5.60+ (Not tested with previous versions)      ║
; ╟──────────────────────────────────────────────────────────────────╢
; ║ Links: github.com/aziascreations/cli-args-pb (Current Version)   ║
; ║        github.com/aziascreations/cli-args-pb/??? (Legacy)        ║
; ╚══════════════════════════════════════════════════════════════════╝

; Docs:

; https://www.gnu.org/software/libc/manual/html_node/Getopt-Long-Options.html

; http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html#tag_12_01

; -b --something -> arguments
; -??? vars -> options (old: flags)
; ... operands

; https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc771080(v=ws.11)

; Structs & Consts

Structure CliArguments
	Short.c
	Long$
	Description$
	
	Flags.i
	
	Values.s[0]
	; Option stuff
	
	IsUsed.b ; ??? (Maybe for simple flags and stuff)
EndStructure

; TODO: Maybe keep a pointer to the parent for an easier cleanup if FreeVerb(...) used.

Structure CliVerb
	Verb$
	Description$
	
	List *Args.CliArguments()
	List *Verbs.CliVerb()
	
	;*ErrorProcedure
	*UsageErrorProcedure
	*ContinueProcedure ; Will be replaced if a better way to get the used verb is found.
					   ; Maybe just return a pointer to the used one ?
	
	; Fcts ptr for easy replacement
	
	; Could be a good fix ? (meh..., probably won't hurt to use both -> Could help for walking to trough the structure)
	IsUsed.b ; ???
EndStructure

;Enumeration CliAr

EnumerationBinary IDK1
	#CLI_ARG_HIDDEN
	
	#CLI_ARG_OPTION ; Meansthe argument has a value (expained in the standard)
	
	#CLI_ARG_DEFAULT
	
	#CLI_ARG_HAS_MULTIPLE_VALUES
	
EndEnumeration

Enumeration IDK3 ; A binary one could be used for multiple ones
				 ; Would allow the use of warnings if needed.
	#CLI_ERROR_ARG_ALREADY_EXISTS
	#CLI_ERROR_PARENT_IS_NULL
	#CLI_ERROR_MALLOC
	#CLI_ERROR_TEST
	
	#CLI_WARNING_EXCESSIVE_VERBS ; Just an example.
EndEnumeration
;#WARNING_MASK = ...

Enumeration IDK4
	#CLI_ARGS_CLEANING_DEFAULT
	#CLI_ARGS_CLEANING_MINIMAL
	#CLI_ARGS_CLEANING_FULL
EndEnumeration

#CLI_ARGS_CLEANING_RECURSIVE = #CLI_ARGS_CLEANING_FULL

Enumeration IDK2
	#CLI_ARGS_PREFIX_DOS
	#CLI_ARGS_PREFIX_UNIX
EndEnumeration

;#CLI_ARG_ARGUMENT = %00000000
#CLI_ARG_HAS_VALUE = #CLI_ARG_OPTION

; #CLI_ARGS_PREFIX_WINDOWS = #CLI_ARGS_PREFIX_DOS
; #CLI_ARGS_PREFIX_SLASH   = #CLI_ARGS_PREFIX_DOS
; #CLI_ARGS_PREFIX_HYPHEN  = #CLI_ARGS_PREFIX_UNIX

; Code

Procedure.l CreateVerb(Verb$ = #Null$, *ParentVerb.CliVerb = #Null, Description$ = #Null$)
	;*Container.CliVerb = AllocateMemory(SizeOf(CliVerb))
	*Container.CliVerb = AllocateStructure(CliVerb)
	
	If *Container
		; Inits the 2 lists
		;InitializeStructure(*Container, CliVerb)
		
		If Verb$ <> #Null$
			If *ParentVerb = #Null ; Or more ???
				FreeStructure(*Container)
				;ProcedureReturn -1
			EndIf
			
			*Container\Verb$ = Verb$
			;*Container\Description$ = Description$
			
			LastElement(*ParentVerb\Verbs())
			If InsertElement(*ParentVerb\Verbs())
				*ParentVerb\Verbs() = *Container
			Else
				Debug "Insertion ERROR !"
			EndIf
			
			IsUsed = #False
			
			; TODO: !!!
			;*UsageErrorProcedure
			;*ContinueProcedure
			
		EndIf
		
		; If given for the root, will be used as the program's description !
		*Container\Description$ = Description$
		
		
		; FreeStructure(*Container)
	Else
		DebuggerWarning("Failed to allocate memory for ArgContainer !")
		ProcedureReturn #CLI_ERROR_MALLOC * -1 ; A better one is already in PB, I couldn't find it.
	EndIf
	
	ProcedureReturn *Container
EndProcedure

; TODO: Macro for easy root creation

Macro CreateRootVerb(Description)
	CreateVerb(#Null$, #Null, Description)
EndMacro

; Free + recursive + or limited (* but the used one)
; Does FreeStructure takes care of discarding everything afterwards ?
Procedure FreeVerb(*Container.CliVerb, CleaningMode = #CLI_ARGS_CLEANING_DEFAULT)
	
	If CleaningMode = #CLI_ARGS_CLEANING_DEFAULT
		Debug Str(*Container)+" - "+*Container\Description$
		FreeStructure(*Container)
		Debug Str(*Container)+" - "+*Container\Description$
	EndIf
	
EndProcedure

Procedure FreeArgument()
	
EndProcedure

;- ?1

Procedure.b IsArgumentUsed()
	
EndProcedure

Procedure.b IsVerbUsed()
	
EndProcedure

; Why ?
Procedure.b IsVerbRoot(*Verb.CliVerb)
	
EndProcedure

Procedure.b DoesVerbExists()
	
EndProcedure

;- !!
; TODO: GetUsedVerb* by walking the verb tree

Procedure.b isArgumentRegistered(*Verb.CliVerb, ArgShort.c = 0, ArgLong.s = #Null$)
	If *Verb And ArgShort And ArgLong <> #Null$ And ListSize(*Verb\Args())
		
		ForEach *Verb\Args()
			; TODO: Could probably be combined
			If (ArgShort And *Verb\Args()\Short = ArgShort) Or (ArgLong <> #Null$ And *Verb\Args()\Long$ = ArgLong)
				ProcedureReturn #True
			EndIf
			
		Next
		
	EndIf
	
	ProcedureReturn #False
EndProcedure


; Macro IsVerbPresent.b(...) for DoesVerbExists.b(...) ?

; Macro for isOption.b(*Arg)

Procedure.l RegisterArgument(*Verb.CliVerb, ArgShort.c, ArgLong.s, Description.s, Flags.i)
	If isArgumentRegistered(*Verb, ArgShort, ArgLong)
		ProcedureReturn -2
	EndIf
	
	*Argument.CliArguments = AllocateStructure(CliArguments)
	
	If *Argument
		*Argument\Short = ArgShort
		*Argument\Long$ = ArgLong
		
		*Argument\Flags = Flags
		
		*Argument\IsUsed = #False
		
		*Argument\Description$ = Description
		
		; TODO: Prepare the array ???
		
		; Insertion
		; TODO: Cleanup in case of an error
		LastElement(*Verb\Args())
		If InsertElement(*Verb\Args())
			*Verb\Args() = *Argument
		Else
			Debug "Insertion ERROR !"
		EndIf
		
	Else
		ProcedureReturn -1
	EndIf
	
	ProcedureReturn *Argument
EndProcedure

; Procedure RegisterShortArgument(*ContainerVerb.CliVerb, ArgShort.c, Description.s, Flags.i)
; 	ProcedureReturn RegisterArgument(*ContainerVerb, ArgShort, #Null$, Description, Flags)
; EndProcedure
; 
; Procedure RegisterLongArgument(*ContainerVerb.CliVerb, ArgLong.s, Description.s, Flags.i)
; 	ProcedureReturn RegisterArgument(*ContainerVerb, 0, ArgLong, Description, Flags)
; EndProcedure

; Prevents useless procedure calls since the compiler might not optimize that.

Macro RegisterShortArgument(ContainerVerb, ArgShort, Description, Flags)
	RegisterArgument(ContainerVerb, ArgShort, #Null$, Description, Flags)
EndMacro

Macro RegisterLongArgument(ContainerVerb, ArgLong, Description, Flags)
	RegisterArgument(ContainerVerb, 0, ArgLong, Description, Flags)
EndMacro

; Tree Dumping procedure & macro
; The compiler might not pick up on the fact that this procedure does nothing without the debugger.
; Appart from modifying the "list index", maybe.
CompilerIf #PB_Compiler_Debugger
	
	; Walks trough the whole thing in the debugger.
	Procedure DumpVerbTree(*Verb.CliVerb, Depth.i = 0)
		Debug Space(Depth) + "Verb: " + *Verb\Verb$
		Debug Space(Depth) + "Desc.: " + *Verb\Description$
		
		Debug Space(Depth) + Str(ListSize(*Verb\Args())) + " argument(s):"
		ForEach *Verb\Args()
			If *Verb\Args()\Short And *Verb\Args()\Long$ <> #Null$
				Debug Space(Depth+2) + "'" + Chr(*Verb\Args()\Short) + "' - " + 
				      #DOUBLEQUOTE$ + *Verb\Args()\Long$ + #DOUBLEQUOTE$
			ElseIf *Verb\Args()\Short
				Debug Space(Depth+2) + "'" + Chr(*Verb\Args()\Short) + "'"
			Else
				Debug Space(Depth+2) + #DOUBLEQUOTE$ + *Verb\Args()\Long$ + #DOUBLEQUOTE$
			EndIf
			
			Debug Space(Depth+2) + "Desc.: " + *Verb\Args()\Description$
			Debug Space(Depth+2) + "- - -"
		Next
	
		Debug Space(Depth) + Str(ListSize(*Verb\Verbs())) + " sub-verb(s):"
		ForEach *Verb\Verbs()
			DumpVerbTree(*Verb\Verbs(), Depth + 4)
		Next
		
		Debug Space(Depth) + "- -"
		
	EndProcedure
	
CompilerElse
	Macro DumpVerbTree(Verb, Depth) : EndMacro
CompilerEndIf


Procedure PrintUsage()
	
EndProcedure



Procedure.s ProcessArgument()
	
EndProcedure

Procedure ParseArguments()
	
EndProcedure

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 278
; FirstLine = 273
; Folding = ----
; EnableXP