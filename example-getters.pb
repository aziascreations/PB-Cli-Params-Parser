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
;
;  * ex-getters-6:
;      Example that demonstrate some "reading errors" that might occur with #ARG_VALUE_ANY or #ARG_VALUE_SEPARATED if not used carefully.
;      (-d -b=123)
;      In this case, -b=123 will be counted/handled as if it was the value for the "-d" options.
;
;  * ex-getters-7:
;      Example that demonstrate some "reading errors" that might occur with #ARG_VALUE_ANY or #ARG_VALUE_SEPARATED if not used carefully.
;      (-cd cat dog)
;      In this case, -c and -d will both attempt to read a separated value, which could lead to errors or the case above.
;      A special "fix" for this will be made in a future version
;
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

RegisterCompleteOption('h', "help", "Print this help", #ARG_VALUE_NONE)

; Doesn't work
;TempCheckDisabler.b = %11111111 | #ERR_EQUAL_SHORT_FLAG

;ParseArguments(#ARG_PREFIX_UNIX)
ParseArguments(#ARG_PREFIX_ANY)

Debug "Setup complete, starting example..."
Debug "- - - - - - - - - - - - - - - - - -"


;
;- Example: Simple check
;

If IsOptionUsed("a")
	Debug "Option a is used, checked with short flag"
	PrintN("Option a is used, checked with short flag")
EndIf

If IsOptionUsed("apple")
	Debug "Option a is used, checked with long flag"
	PrintN("Option a is used, checked with long flag")
EndIf


;
;- Example: Reading text arguments
;

If ListSize(TextArgs())
	ForEach TextArgs()
		Debug "TextArgs() -> "+TextArgs()
		PrintN("TextArgs() -> "+TextArgs())
	Next
Else
	Debug "No text arguments parsed/read"
	PrintN("No text arguments parsed/read")
EndIf


;
;- Example: Reading option values
;

; Getting a string value by pointer (Could probably be improved)
If IsOptionUsed("b")
	*Pointer.String = GetOptionValuePointer("b")
	Debug "Pointer value of 'b': " + *Pointer\s
	PrintN("Pointer value of 'b': " + *Pointer\s)
EndIf

; Getting a string value directly
If IsOptionUsed("b")
	Debug "Direct value of 'b': " + GetOptionValue("b")
	PrintN("Direct value of 'b': " + GetOptionValue("b"))
EndIf

If IsOptionUsed("c")
	Debug "Value of 'c': " + GetOptionValue("c")
	PrintN("Value of 'c': " + GetOptionValue("c"))
EndIf

If IsOptionUsed("d")
	Debug "Value of 'd': " + GetOptionValue("d")
	PrintN("Value of 'd': " + GetOptionValue("d"))
EndIf

If IsOptionUsed("h")
	PrintHelpText()
EndIf
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 37
; FirstLine = 21
; EnableXP