
XIncludeFile "./cli-args.pbi"



#CLI_ARG_HAS_VALUE = #CLI_ARG_OPTION

#CLI_ARGS_PREFIX_WINDOWS = #CLI_ARGS_PREFIX_DOS
#CLI_ARGS_PREFIX_SLASH   = #CLI_ARGS_PREFIX_DOS
#CLI_ARGS_PREFIX_HYPHEN  = #CLI_ARGS_PREFIX_UNIX


; Should it be here or in the main file ?
;#CLI_ARGS_CLEANING_RECURSIVE = #CLI_ARGS_CLEANING_FULL



;- ??
; TODO: GetUsedVerb* by walking the verb tree


; TODO: Macro for easy root creation - Done ?
Macro CreateRootVerb(Description)
	CreateVerb(#Null$, #Null, Description)
EndMacro

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 12
; Folding = -
; EnableXP