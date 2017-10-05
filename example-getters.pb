; ------------------------------------------------------------
; example-getters.pb
; 
; Build targets:
;  * ex-getters-1:
;      Baisc example to see if arguments were present at launch.
;      (-a)
;
;  * ex-getters-2:
;      Basic example to see if text arguments are read correctly.
;      ("Some text" fileName.txt D:\Test ./relative/path)
;
;  * ex-getters-3:
;      Example that shows how joined values can be used/read.
;      (-b="Hello World!" --drum=3.14)
;      Note: A second short flag before -b wasn't used as it is currently unknown how it will react.
;
;  * ex-getters-4:
;      Example that shows how separated values can be used/read.
;      (-c "Hello World!" -ad 3.14)
;      Note: You can use separated values with short flags.
;            However, be carefull if 2 short ones with separated values are used in the same "flag group", it could cause some errors.
;
;  * ex-getters-5:
;      Example that demonstrate the "reading behaviour" of #ARG_VALUE_ANY
;      (--drum="Some beats" "I am not a value")
;      It always checks if the value is joined and if it isn't it gets the next argument.
; ------------------------------------------------------------

;
;- Example setup
;

OpenConsole()

XIncludeFile("cli-args.pb")

RegisterCompleteOption('a', "apple", "Option without value", #ARG_VALUE_NONE)
RegisterCompleteOption('b', "bike", "Option with joined value", #ARG_VALUE_JOINED)
RegisterCompleteOption('c', "car", "Option with separated value", #ARG_VALUE_SEPARATED)
RegisterCompleteOption('d', "drum", "Option with both value type", #ARG_VALUE_ANY)

ParseArguments(#ARG_PREFIX_UNIX)

Debug "Setup complete, starting example..."
Debug "- - - - - - - - - - - - - - - - - -"


;
;- Example: Simple check
;

If IsOptionUsed("a")
	Debug "Option a is used, checked with short flag"
EndIf

If IsOptionUsed("apple")
	Debug "Option a is used, checked with long flag"
EndIf


;
;- Example: Reading text arguments
;

If ListSize(TextArgs())
	ForEach TextArgs()
		Debug "TextArgs() -> "+TextArgs()
	Next
Else
	Debug "No text arguments parsed/read"
EndIf


;
;- Example: Reading option values
;


; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 12
; EnableXP