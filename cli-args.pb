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
;-------- Structure and variables --------
;

;Temp
OpenConsole()

Structure CliArg
  ; Is this the "real" name ?
  FlagShort.s
  FlagLong.s
  FlagDescription.s
  HasValue.b
  DefaultValue.s
EndStructure

; TODO: Checker si le "Global" est vraiment nescessaire
Global NewList ArgsList.CliArg()
Global NewMap ArgsValues.s()

;
;-------- Internal Procedures and stuff --------
;

Procedure IsCliOptionRegistered(Option.s)
  ForEach ArgsList()
    If ArgsList()\FlagShort = Option Or ArgsList()\FlagLong = Option
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

Procedure PrintUsageErrorText(Option.s)
  PrintN("Unsupported option: "+Option)
  If IsCliOptionRegistered("help")
    PrintN("Use --help to see available options")
  EndIf
  Debug "Usage error: "+Option
  End 1
EndProcedure

Procedure ProcessCliOption(Option.s)
  Debug "Processing: "+Option
  If IsCliOptionRegistered(Option) = #False
    PrintUsageErrorText(Option)
  EndIf
  
  ArgsValues(Option) = "TEMP"
EndProcedure

;
;-------- Public Procedures and other stuff --------
;

; TODO: Ajouter des valeurs par défault et autres
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

Procedure PrintHelpText(UsageText.s="[OPTIONS] FILES...", OptDescSpace.i=2)
  OffsetLenght.i = 0
  ; Calculating minimum offset lenght for descriptions
  ForEach ArgsList()
    If Len(ArgsList()\FlagShort)+2+Len(ArgsList()\FlagLong)+OptDescSpace > OffsetLenght
      OffsetLenght = Len(ArgsList()\FlagShort)+2+Len(ArgsList()\FlagLong)+OptDescSpace
    EndIf
  Next
  ;Debug OffsetLenght
  
  PrintN("Usage: "+UsageText)
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

Procedure ParseArguments()
  HasFinishedParsing.b = #False
  
  While HasFinishedParsing = #False
    CurrentArgument.s = ProgramParameter()
    
    If Len(CurrentArgument) = 0
      HasFinishedParsing = #True
      Continue
    EndIf
    
    ; TODO: Supporter les arguments plus petit que 3 caractères.
    ; NOTE: Devrait être bon, pas sûr...
    
    ; TODO: Supporter les "/" pour windows...
    
    ; Vérifie si des tirets sont au début du paramètre
    If Len(ReplaceString(Left(CurrentArgument, 1), "-", "")) = 0
      
      ;Vérifie si plusieurs "arguments courts" sont utilisés
      If Len(ReplaceString(Left(CurrentArgument, 2), "-", "")) > 0
        
        ; TODO: Utiliser une bool pour ne pas utiliser ProgramParameter() 2 fois et faire tout merder.
        For i=1 To Len(CurrentArgument) - 1
          ProcessCliOption(Mid(CurrentArgument, i+1, 1))
        Next
      Else
        ProcessCliOption(ReplaceString(CurrentArgument, "-", ""))
      EndIf
    ElseIf #False
      ; Nope
      ; Windows "/" Part
    Else
      ; Simple texte
    EndIf
  Wend
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


;
;-------- Test: Setup --------
;

RegisterCompleteOption("a","all","Complete option with all args", #False)

RegisterShortOption("b","Short option with all args", #False)
RegisterShortOption("c","Short option without value args")

RegisterLongOption("define","Long option with all args", #False)
RegisterLongOption("eclipse","Long option without value args", #False)

RegisterLongOption("help","Print help text")

ParseArguments()

If IsOptionUsed("all")
  Debug "true1 --all/-a is used (long test)"
EndIf

If IsOptionUsed("a")
  Debug "true2 --all/-a is used (short test)"
EndIf

If IsOptionUsed("eclipse")
  Debug "true3 --eclipse is used"
EndIf

If IsOptionUsed("c")
  Debug "true4 -c is used"
EndIf


;
;-------- Test: Execute --------
;

If IsOptionUsed("help")
  PrintHelpText()
EndIf

Delay(2500)

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 213
; FirstLine = 190
; Folding = --
; EnableUnicode
; EnableXP