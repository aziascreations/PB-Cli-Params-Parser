XIncludeFile "./cli-args.pbi"

; For i=0 To 10
; 	RootVerb = CreateVerb("", #Null, "Hi !")
; 	FreeVerb(RootVerb)
; 	Debug "-----"
; 	RootVerb = CreateVerb("", #Null, "Hi !")
; 	FreeVerb(RootVerb)
; 	Debug "-----"
; Next

Root = CreateRootVerb("Useless Desc")
Verb1 = CreateVerb("commit", Root, "Hello")
Verb2 = CreateVerb("init", Root, "World")

RegisterArgument(Root, 'h', "help", "Prints this help.", 0)
RegisterArgument(Root, 'v', "version", "Prints the version", 0)
RegisterArgument(Verb1, 'h', "help", "Prints this help. -1", 0)
RegisterArgument(Verb2, 'h', "help", "Prints this help. -2", 0)
RegisterLongArgument(Verb2, "test", "IDK my dude", 0)
RegisterShortArgument(Verb2, 'i', "IDK my dude 2", 0)

DumpVerbTree(Root)

End

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 20
; EnableXP