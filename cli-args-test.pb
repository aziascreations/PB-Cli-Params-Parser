OpenConsole()

XIncludeFile "cli-args.pb"

RegisterCompleteOption('a',"all","Complete option With all args", #ARGV_NONE)

RegisterShortOption('b',"Short option With all args", #ARGV_NONE)
RegisterShortOption('c',"Short option without value args")

RegisterLongOption("define","Long option with all args", #ARGV_NONE)
RegisterLongOption("eclipse","Long option without value args", #ARGV_NONE)

RegisterLongOption("help","Print help text")
RegisterShortOption('?',"Print help text")

RegisterCompleteOption('d', "direction", "Complete option with separated value", #ARGV_SEPARATED, "no direction given")

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

If IsOptionUsed("d")
	OptValue.i = GetOptionValue("d")
	Debug "true5 -d or --direction is used -> Value: " + @OptValue
EndIf

If IsOptionUsed("help")
	PrintHelpText()
EndIf

Delay(2500)

; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 50
; EnableXP