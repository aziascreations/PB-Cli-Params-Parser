OpenConsole()

XIncludeFile "cli-args.pb"

RegisterCompleteOption("a","all","Complete option with all args", #False)

RegisterShortOption("b","Short option with all args", #False)
RegisterShortOption("c","Short option without value args")

RegisterLongOption("define","Long option with all args", #False)
RegisterLongOption("eclipse","Long option without value args", #False)

RegisterLongOption("help","Print help text")
RegisterShortOption("?","Print help text")

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

If IsOptionUsed("help")
  PrintHelpText()
EndIf

Delay(2500)

; IDE Options = PureBasic 5.50 (Windows - x64)
; EnableXP