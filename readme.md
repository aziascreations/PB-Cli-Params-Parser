# cli-args-pb

This is a "module" that easily let you define, check and use launch arguments in your console application in PureBasic.

## Usage

### Defining/Declaring options

To define [available] options, you cans use one of these methods:
```asm
; Register an option with both a short and long flag
RegisterCompleteOption(OptShort.s, OptLong.s, OptDesc.s="", OptValue.b=#ARG_VALUE_NONE, OptDefaultValue.s="")
```
```asm
; Register an option with a short flag only
RegisterShortOption(OptShort.s, OptDesc.s="", OptValue.b=#ARG_VALUE_NONE, OptDefaultValue.s="")
```
```asm
; Register an option with a long flag only
RegisterLongOption(OptLong.s, OptDesc.s="", OptValue.b=#ARG_VALUE_NONE, OptDefaultValue.s="")
```

`OptShort.s` - Short flag<br>
`OptLong.s`  - Long flag<br>
`OptDesc.s`  - Option description<br>
`OptValue.b` - Indicates if and how the value should be entered and read:<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_VALUE_NONE` won't attempt to read any value <br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_VALUE_ANY` will read separated value and value after the equal sign<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_VALUE_JOINED` will only read value after an equal sign<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_VALUE_SEPARATED` will only read values separated from the flag<br>
`OptDefaultValue.s` - Default value of the option (Unused, will throw an error if no value is given)

**Warning**:<br>
When using `#ARG_VALUE_SEPARATED` and `#ARG_VALUE_ANY`, you have to be carefull to how the user uses the values as they can lead to some bugs.<br>
See [example-getters.pb](example-getters.pb) 6th and 7th case for examples.

### Parsing launch arguments

Keep in mind that you will need to call `OpenConsole()` before going further as the following procedures might have to print some text in case something goes wrong.

After registering your options, you can parse the launch arguments with the following procedure: 
```asm
ParseArguments(ParsingMode.b=#ARG_PREFIX_ANY, UsageErrorTriggers.b=%11111111)
```

`ParsingMode.b` is used to indicate which type of argument prefix can be used, these are the available options:<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_PREFIX_ANY`: Will parse arguments starting with: "/", "-" or "--"<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_PREFIX_UNIX`: Will parse arguments starting with both "-" and "--"<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_PREFIX_WINDOWS`: Will only parse arguments starting with "/"<br><br>
`UsageErrorTriggers.b` is used to enable or disable some verifications that can call the `PrintUsageError()` procedure:<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ERR_WRONG_PREFIX`: Trigerred when a wrong argument prefix is used<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ERR_OPTION_NOT_REGISTERED`: ???<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ERR_NO_JOINED_VALUE`: Trigerred when no joined value was found.<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ERR_NO_SEPARATED_VALUE`: Trigerred when no separated value was found.<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ERR_EQUAL_SHORT_FLAG`: ???

See ~~[example-parser.pb](#nope)~~ for examples. (Not done yet)

The value of `ParsingMode.b`, or `ArgumentsParsingMode.b` internally/globally, will also influence the way [things will be displayed]<br>
This value will also influence the way that the defaut help text is displayed if `#ARG_PREFIX_ANY` is used, it will act as if `#ARG_PREFIX_UNIX` was used.<br>
Please ignore the last 2 setences, they are wrong...

### Using the damn thing
And if nothing fails, you can use these procedures to see if an option is used and the get its value:

```asm
; Checks if an option is registered and returns #True or #False accordingly.
IsOptionRegistered(Option.s)
```

```asm
; Checks if an option was in the launch arguments and returns #True or #False accordingly.
IsOptionUsed(Option.s)
```
Make sure you always call the previous procedure before attempting to get the option's value since the 2 next procedures will end the program if they fail to find one.

```asm
; Returns a pointer to the option's string value.
GetOptionValuePointer(Option.s)
```

```asm
; Returns a string with the option's value.
; Calls GetOptionValuePointer(Option.s) internally and handles the pointer stuff.
GetOptionValue(Option.s)
```
See [example-getters.pb](example-getters.pb) to see how to use these procedures and/or the ["Pointers and memory access" help page](https://www.purebasic.com/documentation/reference/memory.html) to see how to get a string from a pointer.

The `Option.s` parameter is the option you want to check or get informations from.<br>
You can leave the "-" or "/" at the beginning of the option, they will be removed automatically. (Avoid this, i don't think it's actually true...)

If [text arguments!!!!!!!]

### Other procedures

If you want to print the help text you can call the following procedure:

```asm
PrintHelpText(UsageText.s="", OptDescSpace.i=2, OptionPrefix.s="-")
```
`UsageText.s`: Text displayed on the first line, usually something like "`Usage: command [options] files...`"<br>
`OptDescSpace.i`: Number of spaces between longest option [flags] and it's description. (Default: 2)<br>
`OptionPrefix.s`: Will be removed since `#ARG_WINDOWS` and `#ARG_UNIX` are now implemented. (Will be changed to .b for #ARG_qqch)

If you want to print the usage error message you can call the following procedure:

```asm
PrintUsageErrorText(Option.s, Reason.s="")
```
`Option.s`: The option concerned, will be printed on the first line after "`Unsupported option:`"<br>
`Reason.s`: [The reason], if given it will be added at the end of the first line between [parenthesis].

The usage error procedure will automatically be called if an error occured while parsing the launch arguments.<br>
However, you can use your own method by [change fct pointer, will be added later]

## Additional informations

You can retrieve any non-flag arguments by checking the TextArgs.s list.<br>
Any launch argument that wasn't considered a flag or value will be put there, so alaways check if there isn't any unwanted entries.

### Git-like sub-commands

If you want to use "sub-commands" like in git, you can simply call the "ProgramParameter()" procedure to check if the first argument is a valid command.<br>
If you decide make the command optional, you might lose some arguments since the "ProgramParameter()" procedure always moves forward.<br>
See [example-commands.pb](example-commands.pb) for a basic example on how to do it.

## Planned features

* Possibility to change the PrintUsageError procedure.
* A better test and examples.
* Optionnal sub-commands (not losing the first argument)

## License
[Apache V2](LICENSE)
