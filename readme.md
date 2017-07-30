# cli-args-pb

This is a "module" that easily let you define, check and use launch arguments in your console application in PureBasic.

## Usage

### Defining/Declaring options

To define [available] options, you cans use one of these methods:
```asm
; Register an option with both a short and long [flag]
RegisterCompleteOption(OptShort.s, OptLong.s, OptDesc.s="", OptValue.b=#False)
```
```asm
; Register an option with a short [flag] only
RegisterShortOption(OptShort.s, OptDesc.s="", OptValue.b=#False)
```
```asm
; Register an option with a long [flag] only
RegisterLongOption(OptLong.s, OptDesc.s="", OptValue.b=#False)
```

`OptShort.s` - Short flag<br>
`OptLong.s`  - Long flag<br>
`OptDesc.s`  - Option description<br>
`OptValue.b` - Indicates if the option has a value [unused]

### Parsing launch arguments

After registering your options, you can parse the launch arguments with the following function: 
```asm
ParseArguments(ParsingMode.b=#ARG_ANY)
```

`ParsingMode.b` is used to indicate which type of argument prefix can be used, these are the available options:<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_ANY` will parse arguments starting with: "/", "-" or "--"<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_UNIX` will parse arguments starting with both "-" and "--"<br>
&nbsp;&nbsp;&nbsp;&nbsp;`#ARG_WINDOWS` will only parse arguments starting with "/"

The value of `ParsingMode.b`, or `ArgumentsParsingMode.b` internally/globally, will also influence the way [things will be displayed]

### Using the damn thing
And if everything [goes well], you can use these procedures to see if an option is used and the get the value it [holds]:

```asm
; Checks if an option is registered and returns #True or #False accordingly.
; Usually used internally, could be used in a ["sub-command" scenario].
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
You can leave the "-" or "/" at the beginning of the option, they will be trimmed automatically.

### Other procedures

Keep in mind that [...] you will need to call `OpenConsole()` before.

If you want to print the help text you can call the following procedure:

```asm
PrintHelpText(UsageText.s="", OptDescSpace.i=2, OptionPrefix.s="-")
```
`UsageText.s`: Text displayed on the first line, usually something like "`Usage: command [options] files...`"<br>
`OptDescSpace.i`: Number of spaces between longest option [flags] and it's description. (Default: 2)<br>
`OptionPrefix.s`: Will be removed since `#ARG_WINDOWS` and `#ARG_UNIX` are now implemented.

If you want to print the usage error message you can call the following procedure:

```asm
PrintUsageErrorText(Option.s, Reason.s="")
```
`Option.s`: The option concerned, will be printed on the first line after "`Unsupported option:`"<br>
`Reason.s`: [The reason], if given it will be added at the end of the first line between [parenthesis].

## Additional informations

### Git-like sub-commands

If you want to use "sub-commands" like in git, you can simply call the "ProgramParameter()" function to check if the first argument is valid.
If the sub-command is optional, you [check 1st string or use future? method]
However, you can't reset [the whole thing]

## Planned features

* Arguments/Options with values
  * Type thingy
* Full "language" [customisation] via a .lang file of something like that.
* Better "sub-command" support (if string before all args or something)

## License
[Apache V2](LICENSE)
