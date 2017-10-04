; ------------------------------------------------------------
; cli-args.pb
; 
; (c) Bozet Herwin
; 
; Can be used to easily parse launch arguments and use them in
;  projects.
; 
; Usage:
;   ???
; 
; Additional infos:
;   If you want To use "sub-command" like git, you can simply
;    use ProgramParameter() once before calling ParseArguments().
;   And then you can start registering options depending on the
;    "sub-command".
;   However, you won't be able to easily change the output of
;    PrintHelpText() without having to make one yourself.
; 
; Links:
;   Github: github.com/aziascreations/cli-args-pb
; ------------------------------------------------------------

;
;-------- Personnal notes --------
;

; The OptDefaultValue.s in Register[...]Option() could be used if #ARGV_JOINED is used but no value is given ?

;
;-------- Variables, structures and constants --------
;

Structure CliArg
	FlagShort.s
	FlagLong.s
	FlagDescription.s
	ValueType.b
	;ValueRequired.b
	DefaultValue.s
EndStructure

Enumeration
	#ARG_ANY
	#ARG_WINDOWS
	#ARG_UNIX
EndEnumeration

Enumeration
	#ARGV_NONE
	#ARGV_ANY
	#ARGV_JOINED
	#ARGV_SEPARATED
EndEnumeration

; TODO: Checker si le "Global" est vraiment nescessaire.
Global NewList ArgsList.CliArg()
; NOTE: The short or long "flag" is added here if used and the value too if needed.
Global NewMap ArgsValues.s()
Global ArgumentsParsingMode.b = #ARG_ANY

; TODO: Trouver un meilleur moyen de faire ça et séparer le mode (1ere position) et les autres à la fin.
Global NewList TextArgs.s()
Global NewList TextArgsPosition.i()

;
;-------- Procedures and stuff --------
;

Procedure IsOptionRegistered(Option.s)
	ForEach ArgsList()
		If ArgsList()\FlagShort = Option Or ArgsList()\FlagLong = Option
			ProcedureReturn #True
		EndIf
	Next
	ProcedureReturn #False
EndProcedure

Procedure IsOptionUsed(Option.s)
	ForEach ArgsList()
		If Not (ArgsList()\FlagShort = Option Or ArgsList()\FlagLong = Option)
			Continue
		EndIf
		
		If FindMapElement(ArgsValues(), ArgsList()\FlagShort) Or FindMapElement(ArgsValues(), ArgsList()\FlagLong)
			ProcedureReturn #True
		EndIf
	Next
	
	ProcedureReturn #False
EndProcedure

Procedure GetOptionValueType(Option.s, FallbackValue.b=#ARGV_NONE)
	ForEach ArgsList()
		If Not (ArgsList()\FlagShort = Option Or ArgsList()\FlagLong = Option)
			Continue
		EndIf
		
		ProcedureReturn ArgsList()\ValueType
	Next
	
	ProcedureReturn FallbackValue
EndProcedure

Procedure GetOptionValue(Option.s)
	ForEach ArgsList()
		If Not (ArgsList()\FlagShort = Option Or ArgsList()\FlagLong = Option)
			Continue
		EndIf
		
		If FindMapElement(ArgsValues(), ArgsList()\FlagShort)
			ProcedureReturn FindMapElement(ArgsValues(), ArgsList()\FlagShort)
		ElseIf FindMapElement(ArgsValues(), ArgsList()\FlagLong)
			ProcedureReturn FindMapElement(ArgsValues(), ArgsList()\FlagLong)
		EndIf
	Next
	
	Debug "No value found for "+Option+", use IsOptionUsed() before."
	End 1
EndProcedure

Procedure PrintUsageErrorText(Option.s, Reason.s="")
	Print("Unsupported option: "+Option)
	If Reason
		Print(" ("+Reason+")")
	EndIf
	PrintN("")
	
	If IsOptionRegistered("help") And (ArgumentsParsingMode = #ARG_ANY Or ArgumentsParsingMode = #ARG_UNIX)
		PrintN("Use --help to see available options")
	ElseIf IsOptionRegistered("?") And (ArgumentsParsingMode = #ARG_ANY Or ArgumentsParsingMode = #ARG_WINDOWS)
		PrintN("Use /? to see available options")
	EndIf
	
	Debug "Usage error: "+Option
	End 1
EndProcedure

; TODO: Ajouter des valeurs par défault et autres
; TODO: Utiliser un char pour les courts -> protège des "erreurs"
Procedure RegisterShortOption(OptShort.c, OptDesc.s="no-description", OptValue.b=#ARGV_NONE, OptDefaultValue.s="")
	AddElement(ArgsList())
	ArgsList()\FlagShort = Chr(OptShort)
	ArgsList()\FlagLong = ""
	ArgsList()\FlagDescription = OptDesc
	
	If Not (OptValue = #ARGV_NONE Or OptValue = #ARGV_ANY Or OptValue = #ARGV_JOINED Or OptValue = #ARGV_SEPARATED)
		Debug "Error: No ARGV_* constant used for " + OptShort
		End 1
	EndIf
	
	ArgsList()\ValueType = OptValue
	ArgsList()\DefaultValue = OptDefaultValue
EndProcedure

Procedure RegisterLongOption(OptLong.s, OptDesc.s="no-description", OptValue.b=#ARGV_NONE, OptDefaultValue.s="")
	AddElement(ArgsList())
	ArgsList()\FlagShort = ""
	ArgsList()\FlagLong = OptLong
	ArgsList()\FlagDescription = OptDesc
	
	If Not (OptValue = #ARGV_NONE Or OptValue = #ARGV_ANY Or OptValue = #ARGV_JOINED Or OptValue = #ARGV_SEPARATED)
		Debug "Error: No ARGV_* constant used for " + OptLong
		End 1
	EndIf
	
	ArgsList()\ValueType = OptValue
	ArgsList()\DefaultValue = OptDefaultValue
EndProcedure

Procedure RegisterCompleteOption(OptShort.c, OptLong.s, OptDesc.s="no-description", OptValue.b=#ARGV_NONE, OptDefaultValue.s="")
	AddElement(ArgsList())
	ArgsList()\FlagShort = Chr(OptShort)
	ArgsList()\FlagLong = OptLong
	ArgsList()\FlagDescription = OptDesc
	
	If Not (OptValue = #ARGV_NONE Or OptValue = #ARGV_ANY Or OptValue = #ARGV_JOINED Or OptValue = #ARGV_SEPARATED)
		Debug "Error: No ARGV_* constant used for " + OptShort + " / " + OptLong
		End 1
	EndIf
	
	ArgsList()\ValueType = OptValue
	ArgsList()\DefaultValue = OptDefaultValue
EndProcedure

Procedure PrintHelpText(UsageText.s="Usage: [OPTIONS] FILES...", OptDescSpace.i=2, OptionPrefix.s="-")
	OffsetLenght.i = 0
	; Calculating minimum offset lenght for descriptions
	ForEach ArgsList()
		If Len(ArgsList()\FlagShort)+2+Len(ArgsList()\FlagLong)+OptDescSpace > OffsetLenght
			OffsetLenght = Len(ArgsList()\FlagShort)+2+Len(ArgsList()\FlagLong)+OptDescSpace
		EndIf
	Next
	;Debug OffsetLenght
	
	PrintN(UsageText)
	PrintN("")
	ForEach ArgsList()
		; Check how to print the short flag
		If Len(ArgsList()\FlagShort)=0
			Print("   ")
		Else
			Print(ArgsList()\FlagShort+", ")
		EndIf
		
		; Check if the long flag has to be printed
		If Len(ArgsList()\FlagLong)>0
			Print(ArgsList()\FlagLong)
		EndIf
		
		; Calculate how much space we need to add before the description
		; TODO: Doesn't work correctly, might be the 3 not present at the start of the procedure
		RemainingSpaces.i = OffsetLenght - (3+Len(ArgsList()\FlagLong))
		For i = 1 To RemainingSpaces
			Print(" ")
		Next
		
		PrintN(ArgsList()\FlagDescription)
	Next
EndProcedure

Procedure ProcessCliOption(Option.s)
	Debug "Processing: "+Option
	
	If Not IsOptionRegistered(Option)
		PrintUsageErrorText(Option)
	EndIf
	
	; TODO: Change this to avoid missing separated value if #ARGV_ANY is used.
	OptionValueType = GetOptionValueType(Option)
	
	If OptionValueType = #ARGV_NONE
		ArgsValues(Option) = "ERROR.NULLVALUE"
		
	ElseIf OptionValueType = #ARGV_JOINED
		Debug "Error: Unhandled case used: #ARGV_JOINED"
		;ElseIf OptionValueType = #ARGV_ANY Or OptionValueType = #ARGV_JOINED
		;Temporarely deactivated
		
	ElseIf OptionValueType = #ARGV_ANY Or OptionValueType = #ARGV_SEPARATED
		OptionPotValue.s = ProgramParameter()
		If Len(OptionPotValue) = 0
			PrintUsageErrorText(Option, "No value found")
		Else
			ArgsValues(Option) = OptionPotValue
		EndIf
	EndIf
EndProcedure

Procedure ParseArguments(ParsingMode.b=#ARG_ANY)
	ArgumentsParsingMode = ParsingMode
	
	While #True
		CurrentArgument.s = ProgramParameter()
		
		If Len(CurrentArgument) = 0
			Break
		EndIf
		
		If FindString(CurrentArgument, "-")
			If ArgumentsParsingMode = #ARG_WINDOWS
				Debug "Wrong prefix used, "+CurrentArgument+" will be ignored (Unix instead of Win)"
				PrintUsageErrorText(CurrentArgument, "Wrong prefix")
			EndIf
			
			If FindString(CurrentArgument, "--")
				ProcessCliOption(LTrim(CurrentArgument, "-"))
			Else
				; TODO: Utiliser une bool pour ne pas utiliser ProgramParameter() 2 fois et faire tout merder.
				For i=1 To Len(CurrentArgument) - 1
					ProcessCliOption(Mid(CurrentArgument, i+1, 1))
				Next
			EndIf
		ElseIf FindString(CurrentArgument, "/")
			If ArgumentsParsingMode = #ARG_UNIX
				Debug "Wrong prefix used, "+CurrentArgument+" will be ignored (Win instead of Unix)"
				PrintUsageErrorText(CurrentArgument, "Wrong prefix")
			EndIf
			
			ProcessCliOption(LTrim(CurrentArgument, "/"))
		Else
			Debug "Text argument detected"
			; TODO: Handle this
		EndIf
	Wend
EndProcedure

; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 225
; Folding = --
; EnableXP
; EnableUnicode