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
;-------- Variables, structures and constants --------
;

Structure CliArg
  FlagShort.s
  FlagLong.s
  FlagDescription.s
  HasValue.b
  DefaultValue.s
EndStructure

Enumeration
  #ARG_ANY
  #ARG_WINDOWS
  #ARG_UNIX
EndEnumeration

; TODO: Checker si le "Global" est vraiment nescessaire
Global NewList ArgsList.CliArg()
Global NewMap ArgsValues.s()
Global ArgumentsParsingMode.b = #ARG_ANY

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
    If (ArgsList()\FlagShort = Option Or ArgsList()\FlagLong = Option) = #False
      Continue
    EndIf
    
    If FindMapElement(ArgsValues(), ArgsList()\FlagShort) Or FindMapElement(ArgsValues(), ArgsList()\FlagLong)
      ProcedureReturn #True
    EndIf
  Next
  
  ProcedureReturn #False
EndProcedure

Procedure GetOptionValue(Option.s)
  ProcedureReturn #Null
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
Procedure RegisterShortOption(OptShort.s, OptDesc.s="no-description", OptValue.b=#False)
  AddElement(ArgsList())
  ArgsList()\FlagShort = OptShort
  ArgsList()\FlagLong = ""
  ArgsList()\FlagDescription = OptDesc
  ArgsList()\HasValue = OptValue
EndProcedure

Procedure RegisterLongOption(OptLong.s, OptDesc.s="no-description", OptValue.b=#False)
  AddElement(ArgsList())
  ArgsList()\FlagShort = ""
  ArgsList()\FlagLong = OptLong
  ArgsList()\FlagDescription = OptDesc
  ArgsList()\HasValue = OptValue
EndProcedure

Procedure RegisterCompleteOption(OptShort.s, OptLong.s, OptDesc.s="no-description", OptValue.b=#False)
  AddElement(ArgsList())
  ArgsList()\FlagShort = OptShort
  ArgsList()\FlagLong = OptLong
  ArgsList()\FlagDescription = OptDesc
  ArgsList()\HasValue = OptValue
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
  If IsOptionRegistered(Option) = #False
    PrintUsageErrorText(Option)
  EndIf
  
  ArgsValues(Option) = "TEMP"
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
; CursorPosition = 22
; FirstLine = 6
; Folding = P+
; EnableXP
; EnableUnicode