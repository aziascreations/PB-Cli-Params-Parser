; ------------------------------------------------------------
; cli-args.pb
; 
; (c) Bozet Herwin
; 
; Can be used to easily parse launch arguments and use them in
;  projects.
; 
; Usage:
;   See readme.md
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
;- Personnal notes
;

; The OptDefaultValue.s in Register[...]Option() could be used if #ARG_VALUE_JOINED is used but no value is given ?

; Check if it possible to use a "function pointer" for the help and usage error procedures to be able to change them.

; TODO: Apply default values to seperated and joined? options that passes the #ERR_NO_JOINED_VALUE.

; TODO: Check every instance of default value, mainly in registerers, to see if they use the new constant.

; URGENT: TODO: Fix the pointer in the GetOptionValue procedure. (Solution should be in the help thingy)

;
;- Variables, structures and constants
;

Structure CliArg
	FlagShort.s
	FlagLong.s
	FlagDescription.s
	ValueType.b
	DefaultValue.s
EndStructure

; Used to indicate what kind of prefix can be used.
Enumeration
	#ARG_PREFIX_ANY
	#ARG_PREFIX_WINDOWS
	#ARG_PREFIX_UNIX
EndEnumeration

; Used to indicate how the value of the parameter can be entered.
; If the short one is used, the next argument will always be used.
Enumeration
	#ARG_VALUE_NONE
	#ARG_VALUE_ANY
	#ARG_VALUE_JOINED
	#ARG_VALUE_SEPARATED
EndEnumeration

; Used to enable and disable some triggers for the PrintUsageError procedure
Enumeration
	#ERR_WRONG_PREFIX = %00000001
	#ERR_OPTION_NOT_REGISTERED = %00000010
	#ERR_NO_JOINED_VALUE = %00000100
	#ERR_NO_SEPARATED_VALUE = %00001000
	#ERR_UNKNOWN = %00010000
EndEnumeration

; This value is given to every option that shouldn't have one so it can be easily checked if you use GetOptionValue
;  on one that uses #ARG_VALUE_NONE.
#OPTION_ERROR_VALUE = "You Done Fucked Up Now!!"

Global NewList ArgsList.CliArg()
Global ArgumentsParsingMode.b = #ARG_PREFIX_ANY

; WTF is this shit ?
; NOTE: The short or long "flag" is added here if used and the value too if needed.
Global NewMap ArgsValues.s()
; TODO: Trouver un meilleur moyen de faire ça et séparer le mode (1ere position) et les autres à la fin.
Global NewList TextArgs.s()
;Global NewList TextArgsPosition.i()

;
;- Procedures: Helpers & Getters
;

; Checks if an option is registered and returns #True or #False accordingly.
; Only used internally, has no real usage otherwise, except if you make git-like commands i guess.
Procedure IsOptionRegistered(Option.s)
	ForEach ArgsList()
		If ArgsList()\FlagShort = Option Or ArgsList()\FlagLong = Option
			ProcedureReturn #True
		EndIf
	Next
	ProcedureReturn #False
EndProcedure

; Checks if an option was in the launch arguments and returns #True or #False accordingly.
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

Procedure GetOptionValueType(Option.s, FallbackValue.b=#ARG_VALUE_NONE)
	ForEach ArgsList()
		If Not (ArgsList()\FlagShort = Option Or ArgsList()\FlagLong = Option)
			Continue
		EndIf
		
		ProcedureReturn ArgsList()\ValueType
	Next
	
	ProcedureReturn FallbackValue
EndProcedure

; Returns a pointer to the option value
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

;
;- Procedures: Printers ?
;

; TODO: Implement argument prefixes.
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

Procedure PrintUsageErrorText(Option.s, Reason.s="")
	Print("Unsupported option: "+Option)
	If Reason
		Print(" ("+Reason+")")
	EndIf
	PrintN("")
	
	If IsOptionRegistered("help") And (ArgumentsParsingMode = #ARG_PREFIX_ANY Or ArgumentsParsingMode = #ARG_PREFIX_UNIX)
		PrintN("Use --help to see available options")
	ElseIf IsOptionRegistered("?") And (ArgumentsParsingMode = #ARG_PREFIX_ANY Or ArgumentsParsingMode = #ARG_PREFIX_WINDOWS)
		PrintN("Use /? to see available options")
	EndIf
	
	Debug "Usage error: "+Option
	End 1
EndProcedure

;
;- Procedures: Options Registerers
;

Procedure RegisterShortOption(OptShort.c, OptDesc.s="no-description", OptValue.b=#ARG_VALUE_NONE, OptDefaultValue.s="")
	AddElement(ArgsList())
	ArgsList()\FlagShort = Chr(OptShort)
	ArgsList()\FlagLong = ""
	ArgsList()\FlagDescription = OptDesc
	
	If Not (OptValue = #ARG_VALUE_NONE Or OptValue = #ARG_VALUE_ANY Or OptValue = #ARG_VALUE_JOINED Or OptValue = #ARG_VALUE_SEPARATED)
		Debug "Error: No ARG_VALUE_* constant used for " + OptShort
		End 1
	EndIf
	
	ArgsList()\ValueType = OptValue
	ArgsList()\DefaultValue = OptDefaultValue
EndProcedure

Procedure RegisterLongOption(OptLong.s, OptDesc.s="no-description", OptValue.b=#ARG_VALUE_NONE, OptDefaultValue.s="")
	AddElement(ArgsList())
	ArgsList()\FlagShort = ""
	ArgsList()\FlagLong = OptLong
	ArgsList()\FlagDescription = OptDesc
	
	If Not (OptValue = #ARG_VALUE_NONE Or OptValue = #ARG_VALUE_ANY Or OptValue = #ARG_VALUE_JOINED Or OptValue = #ARG_VALUE_SEPARATED)
		Debug "Error: No ARG_VALUE_* constant used for " + OptLong
		End 1
	EndIf
	
	ArgsList()\ValueType = OptValue
	ArgsList()\DefaultValue = OptDefaultValue
EndProcedure

Procedure RegisterCompleteOption(OptShort.c, OptLong.s, OptDesc.s="no-description", OptValue.b=#ARG_VALUE_NONE, OptDefaultValue.s="")
	AddElement(ArgsList())
	ArgsList()\FlagShort = Chr(OptShort)
	ArgsList()\FlagLong = OptLong
	ArgsList()\FlagDescription = OptDesc
	
	If Not (OptValue = #ARG_VALUE_NONE Or OptValue = #ARG_VALUE_ANY Or OptValue = #ARG_VALUE_JOINED Or OptValue = #ARG_VALUE_SEPARATED)
		Debug "Error: No ARG_VALUE_* constant used for " + OptShort + " / " + OptLong
		End 1
	EndIf
	
	ArgsList()\ValueType = OptValue
	ArgsList()\DefaultValue = OptDefaultValue
EndProcedure

;
;- Procedures: Main Ones
;

; IDK ?
Procedure ProcessCliOption(Option.s, UsageErrorTriggers.b)
	Debug "Processing: "+Option
	
	If Not IsOptionRegistered(Option)
		Debug "Error: Unregistered option ("+Option+")"
		
		If UsageErrorTriggers & #ERR_OPTION_NOT_REGISTERED
			PrintUsageErrorText(Option, "This option doesn't exist.")
		EndIf
		
		ProcedureReturn #False
	EndIf
	
	OptionValueType = GetOptionValueType(Option)
	
	If OptionValueType = #ARG_VALUE_NONE
		ArgsValues(Option) = #OPTION_ERROR_VALUE
	Else
		; Used to prevent a second value check if the value was found in joined mode.
		WasValueRead.b = #False
		
		If OptionValueType = #ARG_VALUE_JOINED Or OptionValueType = #ARG_VALUE_ANY
			If FindString(Option, "=")
				ArgsValues(Option) = Mid(Option, FindString(Option, "="))
			Else
				; No value was found after the equal sign
				Debug "No joined value found for "+Option
				
				If UsageErrorTriggers & #ERR_NO_JOINED_VALUE
					PrintUsageErrorText(Option, "No value found")
				EndIf
				ProcedureReturn #False
			EndIf
		EndIf
		If OptionValueType = #ARG_VALUE_SEPARATED Or (OptionValueType = #ARG_VALUE_ANY And Not WasValueRead)
			PotentialValue.s = ProgramParameter()
			
			If Not Len(PotentialValue)
				Debug "No separated value found for "+Option
				If UsageErrorTriggers & #ERR_NO_SEPARATED_VALUE
					PrintUsageErrorText(Option, "No value found")
				EndIf
				ProcedureReturn #False
			EndIf
			
			; TODO: Check if more verifications have to be done.
			ArgsValues(Option) = PotentialValue
		EndIf
	EndIf
	
	ProcedureReturn #True
EndProcedure

Procedure ParseArguments(ParsingMode.b=#ARG_PREFIX_ANY, UsageErrorTriggers.b = %11111111)
	ArgumentsParsingMode = ParsingMode
	
	While #True
		CurrentArgument.s = ProgramParameter()
		
		; Breaks the while loop when no more arguments are available.
		If Len(CurrentArgument) = 0
			Break
		EndIf
		
		If Left(CurrentArgument, 1) = "-"
			If ArgumentsParsingMode = #ARG_PREFIX_WINDOWS And UsageErrorTriggers & #ERR_WRONG_PREFIX
				Debug "Wrong prefix used with "+CurrentArgument
				PrintUsageErrorText(CurrentArgument, "Wrong prefix used")
			EndIf
			
			If Left(CurrentArgument, 2) = "--"
				ProcessCliOption(LTrim(CurrentArgument, "-"), UsageErrorTriggers)
			Else
				; TODO: Utiliser une bool pour ne pas utiliser ProgramParameter() 2 fois et faire tout merder.
				; What ?
				For i=1 To Len(CurrentArgument) - 1
					ProcessCliOption(Mid(CurrentArgument, i+1, 1), UsageErrorTriggers)
				Next
			EndIf
		ElseIf Left(CurrentArgument, 1) = "/"
			If ArgumentsParsingMode = #ARG_PREFIX_UNIX And UsageErrorTriggers & #ERR_WRONG_PREFIX
				Debug "Wrong prefix used with "+CurrentArgument
				PrintUsageErrorText(CurrentArgument, "Wrong prefix used")
			EndIf
			
			ProcessCliOption(LTrim(CurrentArgument, "/"), UsageErrorTriggers)
		Else
			Debug "Text argument detected"
			; TODO: Improve this part
			AddElement(TextArgs())
			TextArgs() = CurrentArgument
		EndIf
	Wend
EndProcedure
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 353
; FirstLine = 302
; Folding = --
; EnableXP
; EnableUnicode