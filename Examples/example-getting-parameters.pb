i.i = 0

Debug "Grabbing launch parameters with ProgramParameters(...) ..."
For i=0 To CountProgramParameters() - 1
	Debug Str(i) + " - " + ProgramParameter(i)
Next

; Debug #CRLF$ + "Grabbing launch parameters with "
; *ParametersStr.String = GetCommandLine_()
; Debug *ParametersStr
; Debug PeekS(*ParametersStr, #PB_Ascii)
; ;Debug *ParametersStr\s



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 3
; EnableXP
; CommandLine = init --src="./src/" -o "./Output Binary/" -j=4 /test="Hello World"