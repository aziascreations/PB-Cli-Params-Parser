; ╔═══════════════════════════════════════════════════════════════════╦════════╗
; ║ PB-Cli-Params-Parser                              By Bozet Herwin ║ v0.0.3 ║
; ╠═══════════════════════════════════════════════════════════════════╩════════╣
; ║ Note: The major version number will directly jump to 2 to avoid problems   ║
; ║        with the legacy versions.                                           ║
; ╟────────────────────────────────────────────────────────────────────────────╢
; ║ Requirements: PB v5.62+ (Not tested with previous versions)                ║
; ║               Will be tested on older versions (4.10/LTS - 5.60+)          ║
; ╟────────────────────────────────────────────────────────────────────────────╢
; ║ Links:                                                                     ║
; ║     github.com/aziascreations/PB-Cli-Params-Parser             (2+.*)      ║
; ║     github.com/aziascreations/PB-Cli-Params-Parser/tree/legacy (1.*)       ║
; ╟────────────────────────────────────────────────────────────────────────────╢
; ║ License: Apache V2 (See GitHub repo for more info)                         ║
; ╚════════════════════════════════════════════════════════════════════════════╝

;- Notes & Links

; Hidden synonims ?

; INFO: -abc Can't be /abc, but has to be /a /b /c ?
; Windows utils seem to follow this rule.

; PB4.10 doesn't recognise the .i type !
; Maybe go from the 4.? LTS to current

; Docs:

; https://www.gnu.org/software/libc/manual/html_node/Getopt-Long-Options.html

; http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html#tag_12_01

; -b --something -> arguments
; -??? vars -> options (old: flags)
; ... operands

; https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc771080(v=ws.11)


;- Structures

; TODO: Changer le nom au singulier !
Structure CliArguments
	;ParentVerb.CliVerb ; ???
	
	Short.c
	Long$
	Description$
	
	Flags.i
	
	Values.s[0]
	; Option stuff - What ???
	
	; Linked arg stuff (+2d array !!!)
	
	IsUsed.b
EndStructure

; TODO: Maybe keep a pointer to the parent for an easier cleanup if FreeVerb(...) used.
; Maybe for both the argument and verb ?

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
	IsUsed.b
EndStructure


;- Consts

EnumerationBinary CliArgFlags
	#CLI_FLAG_DEFAULT
	
	#CLI_FLAG_OPTION ; Means the argument has a value (expained in the standard)
	;#CLI_FLAG_VALUE_OPTIONAL ; It's usage is strongly discouraged (Why would someone need this ?)
	#CLI_FLAG_VALUE_MULTIPLE ; operands or is this term reserved for the default one ?
	#CLI_FLAG_VALUE_MULTIPLE_LIMITED ; Will stop at the first arg that has -, -- or / depending on the flags.
	
	;#CLI_FLAG_VALUE_POS_SEPARATED
	;#CLI_FLAG_VALUE_POS_JOINED ; With an = sign like "gcc j=4 ..."
	; The user input will be used instead of that.
	
	#CLI_FLAG_HIDDEN ; Won't be shown in the default usage error text
					 ; Added as the last one since it can vary from one implemenntation to another.
					 ; Could be usefull for default ones that do't need to be shown. eg: ls -? --dirs "./" "../"
	
	
	#CLI_FLAG_REPETITIVE ; -n "a" -n "b", not -n "a" "b" ?
	
	; Can be added by the programmer, but this is pretty mmuch useless since it is automatically added later when linking
	#CLI_FLAG_LINKED ; Just use a pointer ??? -t 1 -c 1 -t 2 -c 2 ; where t1 and c1 will be linked, like t2c2.
EndEnumeration


; Errors returned by the procedures in this code.
; Negative numbers are used since the procedure that might return them will also return pointers (>=0).
; And maybe in some case non-zero if something went wrong.
Enumeration CliErrorsIDK3 -1 Step -1
	#CLI_ERROR_ARG_ALREADY_EXISTS
	#CLI_ERROR_PARENT_IS_NULL
	#CLI_ERROR_MALLOC
	#CLI_ERROR_NULL_POINTER
	
	#CLI_ERROR_PARSER_FORMATTING_ERROR
	#CLI_ERROR_PARSER_INVALID_PREFIX
	#CLI_ERROR_PARSER_NO_DEFAULT_DEFINED
	#CLI_ERROR_PARSER_JOINED_VALUE
	#CLI_ERROR_PARSER_ARGUMENT_NOT_FOUND
	#CLI_ERROR_PARSER_DUPLICATES
	
	#CLI_ERROR_PARSER_INTERNAL_ERROR
EndEnumeration

#CLI_ERROR_PARSER_NULL_POINTER = #CLI_ERROR_NULL_POINTER

Enumeration IDK4
	#CLI_ARGS_CLEANING_DEFAULT
	#CLI_ARGS_CLEANING_MINIMAL
	#CLI_ARGS_CLEANING_FULL
EndEnumeration
;#CLI_ARGS_CLEANING_RECURSIVE = #CLI_ARGS_CLEANING_FULL

EnumerationBinary CliParserFlags
	#CLI_PARSER_PREFIX_DOS  ; Only one at a time ?
	#CLI_PARSER_PREFIX_UNIX
	
	;#CLI_PARSER_RETURN_FIRST_USED_VERB
	#CLI_PARSER_STOP_AT_FIRST_USED_VERB ; TODO: Find a shorter name...
	
	#CLI_PARSER_IGNORE_DUPLICATES
	
	#CLI_PARSER_PROCESS_JOINED
	;#CLI_PARSER_DISCARD_JOINED
	
	; Can let the parser use joined value without stating it so ?
	; Seems like a bad idea that's just gonna fuck everything up !
	#CLI_PARSER_SEPARATE_JOINED ; Expands the parameters array by 1 and separates the joined value into the new cell.
	
	#CLI_PARSER_INTERNAL_HAS_JOINED_VALUE
	#CLI_PARSER_INTERNAL_PREFIX_DOS
	#CLI_PARSER_INTERNAL_PREFIX_UNIX
EndEnumeration

Enumeration CliParserParameterType
	#CLI_PROCESSING_LONG
	#CLI_PROCESSING_SHORT_SINGLE
	#CLI_PROCESSING_SHORT_COMBINED ; Will help throw an error if an arg with value is found inside !
	;#CLI_PROCESSING_VERB ; Handled outside of ProcessParameter(...)
	;#CLI_PROCESSING_TEXT  ; Probably gonna be the same case
EndEnumeration

; Trash

;#CLI_ARG_ARGUMENT = %00000000

; Temporarely commented
;#CLI_ARG_HAS_VALUE = #CLI_ARG_OPTION

; #CLI_ARGS_PREFIX_WINDOWS = #CLI_ARGS_PREFIX_DOS
; #CLI_ARGS_PREFIX_SLASH   = #CLI_ARGS_PREFIX_DOS
; #CLI_ARGS_PREFIX_HYPHEN  = #CLI_ARGS_PREFIX_UNIX

;- Code
;-> Creators & Cleaners

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
		;ProcedureReturn #CLI_ERROR_MALLOC * -1 ; A better one is already in PB, I couldn't find it.
		ProcedureReturn #CLI_ERROR_MALLOC
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

; Could lead to some errors if --a and -a were registered as different arguments
Procedure.b IsArgumentUsed(*Verb.CliVerb, Argument$, SearchMode.i = 0)
	If *Verb And Argument$ <> #Null$
		ForEach *Verb\Args()
			If (Chr(*Verb\Args()\Short) = Argument$ Or *Verb\Args()\Long$ = Argument$) And *Verb\Args()\IsUsed
				ProcedureReturn #True
			EndIf
		Next
	Else
		DebuggerError("NULL PTR !")
	EndIf
	
	ProcedureReturn #False
EndProcedure

; Leave Verb$ to its default value to read the IsUsed property directly of of the given verb.
; If a value is given, it will check the sub-verbs instead.
Procedure.b IsVerbUsed(*Verb.CliVerb, Verb$) ;, SearchMode.i = 0)
	If *Verb
		If Verb$ <> #Null$
			ForEach *Verb\Verbs()
				If *Verb\Verbs()\Verb$ = Verb$
					If *Verb\Verbs()\IsUsed
						ProcedureReturn #True
					Else
						Break ; Or simply return false ?
					EndIf
				EndIf
			Next
		Else
			ProcedureReturn Bool(*Verb\Verb$ = Verb$ And *Verb\IsUsed)
		EndIf
	Else
		DebuggerError("NULL PTR !")
	EndIf
	
	ProcedureReturn #False
EndProcedure

; Why ?
Procedure.b IsVerbRoot(*Verb.CliVerb)
	
EndProcedure

; Replaced by is VerbRegistered.b(...)
; Procedure.b DoesVerbExists()
; 	
; EndProcedure


;- !!
; TODO: GetUsedVerb* by walking the verb tree

; ?: Return a bool or a ptr to theparent or searched verb ?
;    Just a bool here since it is a "question"
;    A GetRegisteredVerb could be used in conjuction with this to get the ptr

; TODO: Use the cleaning "flags" for here too.
Procedure.b IsVerbRegistered(*Verb.CliVerb, Verb$, SearchMode.i = 0)
	If Not *Verb
		Debug "NULL PTR @IVR.1"
		;ProcedureReturn #CLI_ERROR_NULL_POINTER
	EndIf
	
	;If *Verb
	ForEach *Verb\Verbs()
		Debug "IsVerbReg() -> " + Verb$ + " ?= " + *Verb\Verbs()\Verb$
		
		If *Verb\Verbs()\Verb$ = Verb$
			Debug "IsVerbReg() -> YUP !"
			ProcedureReturn ListIndex(*Verb\Verbs()) + 1
		EndIf
	Next
	;Else
	;	DebuggerError("Null pointer given !")
	;EndIf
	
	ProcedureReturn 0 ; or #False ?
EndProcedure

;- GetArgumentsFlags ?

Procedure.l GetArgument(*Verb.CliVerb, ArgShort.c = 0, ArgLong$ = #Null$)
	If Not *Verb
		ProcedureReturn #CLI_ERROR_NULL_POINTER
	EndIf
	
	If ArgShort <> 0 Or ArgLong$ <> #Null$
		ForEach *Verb\Args()
			If (ArgLong$ <> #Null$ And *Verb\Args()\Long$ = ArgLong$) Or (ArgShort <> 0 And *Verb\Args()\Short = ArgShort)
				Protected *TempArgPtr.CliArguments = *Verb\Args()
				ProcedureReturn *TempArgPtr
			EndIf
		Next
	EndIf
	
	ProcedureReturn #Null ; or 0/#Null
EndProcedure

; NOTE: Not really tested ! (Will have to be since it's gonna be used when cleaning !, or is it ?)
Procedure.l GetRegisteredVerb(*Verb.CliVerb, Verb$, SearchMode.i = 0)
	If Not *Verb
		DebuggerError("Null pointer given !")
		ProcedureReturn #CLI_ERROR_NULL_POINTER
	EndIf
	
	Debug "GetRegVerb() ->" + Verb$
	
	Protected VerbIndex.i = IsVerbRegistered(*Verb, Verb$, SearchMode)
	
	Debug "GetRegVerb() -> Recieved Index = "+Str(VerbIndex)
	
	If VerbIndex > 0 ; Just in cas errors gets added !
		SelectElement(*Verb\Verbs(), VerbIndex-1)
		Protected *TempVerbPtr.CliVerb = *Verb\Verbs()
		;Debug "T1-"+*TempVerbPtr\Verb$
		ProcedureReturn *TempVerbPtr
		
		;Protected *TempVerbPtr.CliVerb = SelectElement(*Verb\Verbs(), VerbIndex)
		;Debug "T1-"+*TempVerbPtr\Verb$
		;ProcedureReturn *TempVerbPtr
		
		;ProcedureReturn SelectElement(*Verb\Verbs(), VerbIndex)
	Else
		ProcedureReturn #Null
	EndIf
EndProcedure

Procedure.l GetVerbDefaultArgument(*Verb.CliVerb)
	If Not *Verb
		ProcedureReturn #CLI_ERROR_NULL_POINTER
	EndIf
	
	ForEach *Verb\Args()
		If *Verb\Args()\Flags & #CLI_FLAG_DEFAULT
			Protected *TempVerbPtr.CliVerb = *Verb\Args()
			ProcedureReturn *TempVerbPtr
		EndIf
	Next
	
	ProcedureReturn #False ; or 0
EndProcedure

; Only used internally
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
		If AddElement(*Verb\Args())
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

;- Were arguments used in previous verbs procedure ?

;- Was option used in parent procedure ?

; Tree Dumping procedure & macro
; The compiler might not pick up on the fact that this procedure does nothing without the debugger.
; Appart from modifying the "list index", maybe.

; Reset all the variables for a second parsing or something like that
;- Reset Verb Tree() ?

; This procedure is quickly cobbled together, but it works and should one be used when debugging.
CompilerIf #PB_Compiler_Debugger
	
	; Walks trough the whole thing in the debugger.
	Procedure DumpVerbTree(*Verb.CliVerb, Depth.i = 0, Base$ = #Null$)
		;Debug "+--|"
		
		If Len(Base$)
			Debug RTrim(RTrim(Base$), "|") + "+- " + *Verb\Verb$
		Else
			Debug "_ROOT_"
			Base$ = "|" + Space(2)
		EndIf
		
		Debug Base$ + "Desc.: "+*Verb\Description$
		
		If *Verb\IsUsed
			Debug Base$ + "IsUsed: True"
		Else
			Debug Base$ + "IsUsed: False"
		EndIf
		
		If *Verb\ContinueProcedure
			Debug Base$ + "Has continue callback"
		EndIf
		
		If *Verb\UsageErrorProcedure
			Debug Base$ + "Has usage error callback"
		EndIf
		
		Debug Base$
		
		If ListSize(*Verb\Args())
			Debug Base$ + "Argument(s): ["+Str(ListSize(*Verb\Args()))+"]"
			;ArgBase$ = Base$ + "|" + Space(3)
			ArgBase$ = RTrim(RTrim(Base$ + "|" + Space(2)), "|") + "+- "
			ContBase$ = Base$ + "|" + Space(2)
			ForEach *Verb\Args()
				Title$ = ArgBase$
				If *Verb\Args()\Short
					Title$ + "'"+ Chr(*Verb\Args()\Short) +"' "
				EndIf
				If *Verb\Args()\Long$ <> #Null$
					Title$ + #DOUBLEQUOTE$ + *Verb\Args()\Long$ + #DOUBLEQUOTE$
				EndIf
				
				Debug Title$
				
				If *Verb\Args()\Description$ <> #Null$
					Debug ContBase$ + "Desc.: "+*Verb\Args()\Description$
				EndIf
				
				If *Verb\Args()\Flags & #CLI_FLAG_HIDDEN
					Debug ContBase$ + "Hidden"
				EndIf
				
				If *Verb\Args()\IsUsed
					Debug ContBase$ + "IsUsed: True"
				Else
					Debug ContBase$ + "IsUsed: False"
				EndIf
				
				If ListIndex(*Verb\Args()) <> ListSize(*Verb\Args()) - 1
					Debug ContBase$
				EndIf
				
				; More infos
				
			Next
			Debug Base$
		EndIf
		
		If ListSize(*Verb\Verbs())
			Debug Base$ + "Sub-Verb(s): ["+Str(ListSize(*Verb\Verbs()))+"]"
			ForEach *Verb\Verbs()
				DumpVerbTree(*Verb\Verbs(), Depth + 1, Base$ + "|" + Space(2))
			Next
		EndIf
		
	EndProcedure
	
CompilerElse
	;Macro DumpVerbTree(Verb, Depth, Base$) : EndMacro
	
	Procedure DumpVerbTree(*Verb.CliVerb, Depth.i = 0, Base$ = #Null$)
		
	EndProcedure
	
CompilerEndIf


Procedure PrintUsage()
	
EndProcedure



; EnumerationBinary CliParserFlags
; 	
; 	#CLI_PARSER_INTERNAL_HAS_JOINED_VALUE
; EndEnumeration
; 
; Enumeration CliParserParameterType
; 	#CLI_PROCESSING_LONG
; 	#CLI_PROCESSING_SHORT_SINGLE
; 	#CLI_PROCESSING_SHORT_COMBINED ; Will help throw an error if an arg with value is found inside !
; 	;#CLI_PROCESSING_VERB ; Handled outside of ProcessParameter(...)
; 	;#CLI_PROCESSING_TEXT
; EndEnumeration


; Could be renamed to ProcessParameter if text is involved !
; Separated from from ParseArguments(...) main loop to improve readability and to avoid having a 200+ lines procedure.
Procedure ProcessParameter(*Verb.CliVerb, Array Params$(1), CurrentArgumentIndex.i, ParameterType, Flags.i)
	CompilerIf #PB_Compiler_Debugger
		If ParameterType = #CLI_PROCESSING_LONG
			Debug "Processing long..."
		ElseIf ParameterType = #CLI_PROCESSING_SHORT_SINGLE
			Debug "Processing single short..."
		ElseIf ParameterType = #CLI_PROCESSING_SHORT_COMBINED
			Debug "Processing joined shorts..."
		Else
			Debug "Processing unknown..."
		EndIf
	CompilerEndIf
	
	; EnableExplicit related stuff...
	Protected ArgShort.c = 0, ArgLong$ = #Null$, i.i = 0, *UsedArg.CliArguments = #Null
	
	Debug "Processing: "+Params$(CurrentArgumentIndex)
	
	If ParameterType = #CLI_PROCESSING_SHORT_COMBINED
		; #CLI_PARSER_INTERNAL_HAS_JOINED_VALUE isn't checked here since that error should be catched before this procedure is called
		
		Debug Params$(CurrentArgumentIndex)
		
		For i=0 To Len(Params$(CurrentArgumentIndex)) - 1 - 1 ; Second -1 for the "-"
			ArgShort = Asc(Mid(Params$(CurrentArgumentIndex), i+1+1, 1))
			*UsedArg = GetArgument(*Verb, ArgShort, #Null$)
			
			Debug "-> "+Chr(ArgShort) + " " + Str(*UsedArg)
			
			; TODO: Check if linked or invalid combination !!!!
			
			If *UsedArg = #Null
				Debug "Not found !"
				ProcedureReturn #CLI_ERROR_PARSER_ARGUMENT_NOT_FOUND
			ElseIf *UsedArg < 0
				ProcedureReturn *UsedArg
			Else
				Debug "Gné"
				If *UsedArg\IsUsed And Not Flags & #CLI_PARSER_IGNORE_DUPLICATES
					ProcedureReturn #CLI_ERROR_PARSER_DUPLICATES
				Else
					*UsedArg\IsUsed = #True
				EndIf
			EndIf
		Next
		
	Else ; #CLI_PROCESSING_LONG or #CLI_PROCESSING_SHORT_SINGLE implied
		 ; Separated because they can have values (joined or separated) and are processed in a different manner
		
		CurrentParameter$ = LTrim(LTrim(Params$(CurrentArgumentIndex), "/"), "-")
		
		; I don't know which is the best solution ?
		
		;If Flags & #CLI_PARSER_INTERNAL_PREFIX_UNIX
		;	CurrentParameter$ = Right(CurrentParameter$, Len(CurrentParameter$)-2)
		;ElseIf Flags & #CLI_PARSER_INTERNAL_PREFIX_DOS
		;	CurrentParameter$ = Right(CurrentParameter$, Len(CurrentParameter$)-1)
		;Else
		;	; TODO: Avoid throwing it ?
		;	ProcedureReturn #CLI_ERROR_PARSER_INTERNAL_ERROR
		;EndIf
		
		; TODO: use #CLI_PROCESSING_SHORT_SINGLE to check if a character should be used to get the used arg !
		
		; TODO: If joined, separate and don't read next array entry if arg is an option !
		;If
		
		; Grabbing the used verb part
		; Checking if a joined value is present
		
		*UsedArg.CliArguments = #Null
		ArgChar.c = 0
		
		If Flags & #CLI_PARSER_INTERNAL_HAS_JOINED_VALUE
			If Asc(CurrentParameter$) = '=' Or Asc(CurrentParameter$) = ':'
				ProcedureReturn #CLI_ERROR_PARSER_FORMATTING_ERROR
			EndIf
			
			; A bit disgusting, but since only 2 chars can be used to join the value, it is the most efficient and safe way to do it.
			CutIndex.i = FindString(CurrentParameter$, "=", 2)
			If Not CutIndex
				CutIndex = FindString(CurrentParameter$, ":", 2)
				If Not CutIndex
					ProcedureReturn #CLI_ERROR_PARSER_INTERNAL_ERROR
				EndIf
			EndIf
			
			Argument$ = Left(CurrentParameter$, CutIndex)
			
			Debug "Cut: "+CurrentParameter$+" to "+Argument$
			
			; INFO: Could probably be improved with the second one in the else part
			If ParameterType = #CLI_PROCESSING_SHORT_SINGLE
				ArgChar = Asc(Argument$)
				Argument$ = #Null$
			EndIf
			
			*UsedArg = GetArgument(*Verb, ArgChar, Argument$)
		Else
			; No joined value
			If ParameterType = #CLI_PROCESSING_SHORT_SINGLE
				*UsedArg = GetArgument(*Verb, Asc(CurrentParameter$), #Null$)
			Else
				*UsedArg = GetArgument(*Verb, 0, CurrentParameter$)
			EndIf
		EndIf
		
		If Not *UsedArg
			ProcedureReturn #CLI_ERROR_PARSER_ARGUMENT_NOT_FOUND
		ElseIf *UsedArg < 0
			ProcedureReturn *UsedArg
		EndIf
		
		If *UsedArg\IsUsed And Not Flags & #CLI_PARSER_IGNORE_DUPLICATES
			ProcedureReturn #CLI_ERROR_PARSER_DUPLICATES
		EndIf
		
		*UsedArg\IsUsed = #True
		
		; Now, if required, parse values
		
	EndIf
	
	; >=0 if no error, returns the current arg index to where it should be after processing the current argument.
	; Might move forward if a value is read.
	; Keep in mind that it will be increased by 1 in ParseArguments(...) at the end of the loop !
	ProcedureReturn CurrentArgumentIndex
EndProcedure

; TODO: Allow an array in the params so it can be fixed in some cases

Procedure ParseArguments(*RootVerb.CliVerb, Flags = #CLI_PARSER_PREFIX_UNIX, FirstParameterIndex.i = -1, CustomParameters$ = "", Delimiter$ = " ")
	; EnableExplicit related stuff...
	Protected *CurrentVerb.CliVerb = *RootVerb
	Protected CurrentParameterIndex.i = 0;, NewParameterIndex.i == to ReturnValue
	Protected Dim Parameters$(0)
	Protected i.i, ArgProcessorFlags = 0 ; TODO: Check if the 0 could cause some sign error
	Protected ReturnValue = 0
	
	; Basic check(s)
	If Not *CurrentVerb
		DebuggerError("Null pointer given in a procedure parameter !")
		ProcedureReturn #CLI_ERROR_PARSER_NULL_POINTER
	EndIf
	
	; TODO: Check if flags are valid
	
	; TODO: Check if joined stuff first parsable char is not the separator itself
	
	; Reading parameters into an array
	
	; This array is not really needed since any procedure can call "ProgramParameter([n])", but
	;  it can quickly become unclear which current entry is being processed.
	; And it allows the use of custom program parameters / preprocessing.
	; And it doesn't waste too much ressources, maybe less than calling ProgramParameter() over and over even.
	; Actually it can be usefull if "FirstParameterIndex" to avoid using stuff like:
	;  Var$ = ProgramParameter(StartIndex + CurrentIndex + OffsetForSomething)...
	
	; TODO: Use FirstParameterIndex here !
	
	If CustomParameters$ <> #Null$ And Delimiter$ <> #Null$
		; TODO: Could lead to some errors if delimiter is == to : or =
		; Cleaning String
		CustomParameters$ = LTrim(RTrim(CustomParameters$, Delimiter$), Delimiter$)
		While FindString(CustomParameters$, Delimiter$ + Delimiter$)
			CustomParameters$ = ReplaceString(CustomParameters$, Delimiter$+Delimiter$, Delimiter$)
		Wend
		
		; Copying string into Array
		ReDim Parameters$(CountString(CustomParameters$, Delimiter$) + 1)
		
		For i=0 To ArraySize(Parameters$())
			Parameters$(i) = StringField(CustomParameters$, i+1, Delimiter$)
		Next
		
		;ExplodeStringToArray(Parameters$(), CustomParameters$, Delimiter$)
	Else
		ReDim Parameters$(CountProgramParameters())
		
		For i=0 To CountProgramParameters()
			Parameters$(i) = ProgramParameter(i)
		Next
	EndIf
	
	;{ Parameter array debug output...
	CompilerIf #PB_Compiler_Debugger
		Debug "List of parameters to be processed:"
		For i = 0 To ArraySize(Parameters$())-1
			Debug Str(i) + " - " + Parameters$(i)
		Next
	CompilerEndIf
	;}
	
	; TODO: #CLI_..._FIX_JOINED stuff here, or above ?
	
	;Parameters$(CurrentParameterIndex)
	
	; Preparing some stuff...
	; ResetVerbTree(*CurrentVerb) ; Resets the root - Don't call this inside any procedure ine this module !
	*CurrentVerb\IsUsed = #True
	
	; Now we're getting into it.  Oh mama, get ready for the spaghetti.
	While CurrentParameterIndex < ArraySize(Parameters$())
		ArgProcessorFlags = 0
		ReturnValue = 0
		
		Debug "Parsing: " + Parameters$(CurrentParameterIndex)
		
		If Asc(Parameters$(CurrentParameterIndex)) = '-'
			; TODO: Verify is "#.*_UNIX" is used !
			; TODO: Check if there is a joined variable here ?
			; INFO: ProcessParameter(...) will take care of separating them !
			; TODO: See if the use of combined value could be forbidden with #CLI_PARSER _... flags ?
			If FindString(Parameters$(CurrentParameterIndex), "=") ; And last char != "[=|:]", or find(":")
				ArgProcessorFlags = ArgProcessorFlags | #CLI_PARSER_INTERNAL_HAS_JOINED_VALUE
			EndIf
			
			If Len(Parameters$(CurrentParameterIndex)) >= 3 And Left(Parameters$(CurrentParameterIndex), 2) = "--"
				;ProcessParameter(LTrim(CurrentArgument$, "-"), CurrentArgumentIndex, #CLI_PROCESSING_LONG)
				; 1 long
				
				ReturnValue = ProcessParameter(*CurrentVerb, Parameters$(), CurrentParameterIndex, #CLI_PROCESSING_LONG, Flags | ArgProcessorFlags | #CLI_PARSER_INTERNAL_PREFIX_UNIX)
				If ReturnValue < 0
					Debug "Arg processing error returned at P.01"
					ProcedureReturn ReturnValue
				Else
					Debug "Arg processing succedded @1 "+CurrentParameterIndex+" -> "+ReturnValue
					CurrentParameterIndex = ReturnValue
				EndIf
				
			ElseIf Len(Parameters$(CurrentParameterIndex)) >= 2 And Left(Parameters$(CurrentParameterIndex), 2) <> "--"
				; 1 or more shorts
				
				; TODO: Check for only 1 short !!!
				
				If Len(Parameters$(CurrentParameterIndex)) = 2 Or
				   (ArgProcessorFlags & #CLI_PARSER_INTERNAL_HAS_JOINED_VALUE And
				   	((FindString(Parameters$(CurrentParameterIndex), "=")) = 3 Or
				   	(FindString(Parameters$(CurrentParameterIndex), ":")) = 3))
					
					; Single short with or without joined value
					
					ReturnValue = ProcessParameter(*CurrentVerb, Parameters$(), CurrentParameterIndex, #CLI_PROCESSING_SHORT_SINGLE, Flags | ArgProcessorFlags)
					
				Else
					; Combined shorts with or without joined value
					
					If ArgProcessorFlags & #CLI_PARSER_INTERNAL_HAS_JOINED_VALUE
						ProcedureReturn #CLI_ERROR_PARSER_JOINED_VALUE
					EndIf
					
					; TODO: Check if an arg has a value in the process procedure.
					ReturnValue = ProcessParameter(*CurrentVerb, Parameters$(), CurrentParameterIndex, #CLI_PROCESSING_SHORT_COMBINED, Flags | ArgProcessorFlags)
				EndIf
				
				If ReturnValue < 0
					Debug "Arg processing error returned at P.02"
					ProcedureReturn ReturnValue
				Else
					Debug "Arg processing succedded @2: "+CurrentParameterIndex+" -> "+ReturnValue
					CurrentParameterIndex = ReturnValue
				EndIf
				
				; TODO: Remove when version is at 2.* !
				;CompilerIf #PB_Compiler_Debugger
				;	If CurrentParameterIndex<>ReturnValue
				;		DebuggerWarning("!!! CurrentParameterIndex should not have changed when parsing multiple short args !!! @P.02")
				;		DebuggerWarning("Something is wrong !")
				;	EndIf
				;CompilerEndIf
				
				; Actually fuck this, it might be better to not have a silent error and risk getting a syntax error !
				;CurrentParameterIndex = ReturnValue ; Just to be safe.
				
				; process, separately if needed
				; INFO: #CLI_PROCESSING_SHORT_COMBINED will be usefull if an arg inside also requires a value. 
				; What the actual fuck is that suposed to mean ?
				
				; What about optional values ? - Got axed.
			Else
				; The thing is fucked.
				; TODO: add an error return
				Debug "You done fucked up !"
				Debug "-> "+Parameters$(CurrentParameterIndex)
				ProcedureReturn #CLI_ERROR_PARSER_FORMATTING_ERROR
			EndIf
		ElseIf Asc(Parameters$(CurrentParameterIndex)) = '/'
			
		Else ; Verb or text
			
			; TODO: Do not check if a verb is the text value in the process procedure since a value
			;  should NEVER be given before a verb, except If joined

			Debug "Text|Verb: "+Parameters$(CurrentParameterIndex)
			
			Protected *NewlyUsedVerb.CliVerb = GetRegisteredVerb(*CurrentVerb, Parameters$(CurrentParameterIndex))
			
			; TODO: Check if a text parameter couldn't be interpreted as a verb by error
			
			If *NewlyUsedVerb
				Debug "Verb !"
				; The processed entry is a verb
				
				; Not sure on how to handle it :/
				;iif Flags & #CLI_PARSER_STOP_AT_FIRST_USED_VERB
				;	ProcedureReturn *CurrentVerb
				
				*CurrentVerb = *NewlyUsedVerb
				*CurrentVerb\IsUsed = #True
			Else
				If *NewlyUsedVerb < 0
					ProcedureReturn *NewlyUsedVerb
				EndIf
				
				; Text
				
				Debug "Text ! -> @verb="+Str(*NewlyUsedVerb)
				Protected *DefaultArgument.CliArguments = GetVerbDefaultArgument(*CurrentVerb)
				
				If Not *DefaultArgument
					ProcedureReturn #CLI_ERROR_PARSER_NO_DEFAULT_DEFINED
				ElseIf *DefaultArgument < 0
					ProcedureReturn *DefaultArgument ; Error code, not a pointer ?
				Else
					; Good, now parse
				EndIf
				
			EndIf
		EndIf ; END of verb or text
		
		CurrentParameterIndex = CurrentParameterIndex + 1
	Wend
	
	ProcedureReturn *CurrentVerb
EndProcedure


;- Test

CompilerIf #PB_Compiler_IsMainFile
	Root = CreateRootVerb("Program root")
	CmdInit = CreateVerb("init", Root, "Init command")
	;CmdInitBase = CreateVerb("base", CmdInit, "Init Base command")
	;CmdClone = CreateVerb("clone", Root, "Clone command")
	
	RegisterArgument(Root, 'h', "help", "Prints this help (R)", 0)
	
	RegisterArgument(Root, 'a', "allo", "Prints this help (R)", 0)
	RegisterArgument(Root, 'b', "batch", "Prints this help (R)", 0)
	RegisterArgument(Root, 'c', "cock-sauce", "Prints this help (R)", 0)
	RegisterArgument(Root, 'd', "hurdur", "Prints this help (R)", 0)
	
	RegisterArgument(CmdInit, 'h', "help", "Prints this help (I)", #CLI_FLAG_HIDDEN)
	RegisterArgument(CmdInit, 'c', "cock-sauce", "Prints this help (R)", 0)
	RegisterArgument(CmdInit, 'd', "hurdur", "Prints this help (R)", 0)
	
	;RegisterArgument(CmdInitBase, 'h', "help", "Prints this help (IB)", 0)
	;RegisterArgument(CmdClone, 'h', "help", "Prints this help (C)", 0)
	;RegisterArgument(Root, 'v', "version", "Prints the version", 0)
	
	If Root <> #Null
		DumpVerbTree(Root)
		;End
		Debug ""
		
		*UsedVerb = ParseArguments(Root, #CLI_PARSER_PREFIX_UNIX, -1, "--help init --help -d", " ")
		
		;*UsedVerb = ParseArguments(Root, #CLI_PARSER_PREFIX_UNIX, -1, "init --help --get-fucked", " ")
		
		If *UsedVerb < 0
			Debug "Error: (See next line !)"
			Select *UsedVerb
				Case #CLI_ERROR_NULL_POINTER
					Debug "Null pointer"
				Case #CLI_ERROR_PARSER_DUPLICATES
					Debug "Duplicates"
				Case #CLI_ERROR_PARSER_ARGUMENT_NOT_FOUND
					Debug "Arg not found"
				Case #CLI_ERROR_PARSER_FORMATTING_ERROR
					Debug "Formatting error"
				Case #CLI_ERROR_PARSER_INVALID_PREFIX
					Debug "Invalid prefix"
				Case #CLI_ERROR_PARSER_JOINED_VALUE
					Debug "Joined value"
				Case #CLI_ERROR_PARSER_NO_DEFAULT_DEFINED
					Debug "No default"
				Case #CLI_ERROR_PARSER_NULL_POINTER
					Debug "Null pointer"
				Default
					Debug "[Default case]"
			EndSelect
		ElseIf *UsedVerb = #Null
			Debug "Null 0.01"
		Else
			Debug "Good"
		EndIf
		
		Debug ""
		
		DumpVerbTree(Root)
		
		End
		
		If *UsedVerb <> #Null
			DumpVerbTree(*UsedVerb)
		Else
			Debug "NULL PTR !!!"
		EndIf
	Else
		Debug "NULL PTR !!!"
	EndIf
	
CompilerEndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 987
; FirstLine = 958
; Folding = ---v-
; EnableXP
; CommandLine = init --help