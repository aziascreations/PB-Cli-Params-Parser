OpenConsole()

XIncludeFile "cli-args.pb"

RegisterCompleteOption('a',"all","Complete option With all args", #ARG_VALUE_NONE)

RegisterShortOption('b',"Short option With all args", #ARG_VALUE_NONE)
RegisterShortOption('c',"Short option without value args")

RegisterLongOption("define","Long option with all args", #ARG_VALUE_NONE)
RegisterLongOption("eclipse","Long option without value args", #ARG_VALUE_NONE)

RegisterLongOption("help","Print help text")
RegisterShortOption('?',"Print help text")

RegisterCompleteOption('d', "direction", "Complete option with separated value", #ARG_VALUE_SEPARATED, "no direction given")
RegisterCompleteOption('f', "find", "Complete option with separated value", #ARG_VALUE_SEPARATED, "no luck finding that unicorn huh ?")

RegisterCompleteOption('h', "height", "Complete option with joined value", #ARG_VALUE_JOINED, "0 meters")

ParseArguments()
;ParseArguments(#ARG_UNIX)
;ParseArguments(#ARG_WINDOWS)

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

If IsOptionUsed("?")
	Debug "true5 -? or /? is used"
EndIf

; See the "Pointers" help page to see how to get strings from pointers
If IsOptionUsed("d")
	*OptValue.String = GetOptionValuePointer("d")
	Debug "true5 -d or --direction is used -> Value: " + *OptValue\s
EndIf

If IsOptionUsed("f")
	*OptValue.String = GetOptionValuePointer("f")
	Debug "true5 -f or --find is used -> Value: " + *OptValue\s
EndIf

If IsOptionUsed("d")
	OptValue.s = GetOptionValue("d")
	Debug "" + OptValue
EndIf

If IsOptionUsed("help")
	PrintHelpText()
EndIf

Delay(2500)

; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 51
; FirstLine = 26
; EnableXP