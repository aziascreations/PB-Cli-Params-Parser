# cli-args-pb

This is a "module" that easily let you define, check and use launch arguments in your console application in PureBasic.

## Usage

### Defining/Declaring options

To define [available] options, you cans use one of these methods:
```asm
; Register an option with both a short and long [flag]
RegisterCompleteOption(OptShort.s, OptLong.s, OptDesc.s="", OptValue.b=#ARG_VALUE_NONE, OptDefaultValue.s="")
```
```asm
; Register an option with a short [flag] only
RegisterShortOption(OptShort.s, OptDesc.s="", OptValue.b=#ARG_VALUE_NONE, OptDefaultValue.s="")
```
```asm
; Register an option with a long [flag] only
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

### Parsing launch arguments

Keep in mind that you will need to call `OpenConsole()` before going further as the following procedure might have to print some text in case something goes wrong.

After registering your options, you can parse the launch arguments with the following function: 
```asm
ParseArguments(ParsingMode.b=#ARG_ANY)
```

`ParsingMode.b` is used to indicate which type of argument prefix can be used, these are the available options:<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_ANY` will parse arguments starting with: "/", "-" or "--"<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_UNIX` will parse arguments starting with both "-" and "--"<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_WINDOWS` will only parse arguments starting with "/"

The value of `ParsingMode.b`, or `ArgumentsParsingMode.b` internally/globally, will also influence the way [things will be displayed]<br>
This value will also influence the way that the defaut help text is displayed if `#ARG_ANY` is used, it will act as if `#ARG_UNIX` was used.

### Using the damn thing
And if everything [goes well], you can use these procedures to see if an option is used and the get the value it [holds]:

```asm
; Checks if an option is registered and returns #True or #False accordingly.
IsOptionRegistered(Option.s)
```

```asm
; Checks if an option was in the launch arguments and returns #True or #False accordingly.
IsOptionUsed(Option.s)
```

```asm
; Just returns #False for the moment, might have type-specific procedures later.
GetOptionValue(Option.s)
```

The `Option.s` parameter is the option you want to check or get informations from.<br>
You can leave the "-" or "/" at the beginning of the option, they will be removed automatically.

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

If you want to use "sub-commands" like in git, you can simply call the "ProgramParameter()" function to check if the first argument is valid.
If the sub-command is optional, you [check 1st string or use future? method]
However, you can't reset [the whole thing]

## Planned features

* Possibility to change the PrintUsageError procedure.
* A better test and examples.

## License
[Apache V2](LICENSE)
