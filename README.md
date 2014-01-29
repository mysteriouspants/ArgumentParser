# FSArgumentParser

A short, awesome, and *really useful* tool for rapidly parsing command-line arguments in a declarative manner using Objective-C.

    FSArgumentSignature
      * force = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --force]"],
      * soft = [FSArgumentSignature argumentSignatureWithFormat:@"[-s --soft]"],
      * outputFile = [FSArgumentSignature argumentSignatureWithFormat:@"[-o --output-file of]=",
      * inputFile = [FSArgumentSignature argumentSignatureWithFormat:@"[-i --input-file if]={1,}"];
      
    NSArray * signatures = @[force, soft, outputFile, inputFile];
    
    FSArgumentPackage * package =
     [[NSProcessInfo currentProcess] fsargs_parseArgumentsWithSignatures:signatures];

    if ([package booleanValueOfSignature:soft]) {
        // presumably you'd do something
    }

    if ([package firstObjectForSignature:inputFile]) {
        printf("dude, you gotta specify a file!\n");
        return -1;
    }

## Features: It Just Works

You're probably already excited about the nice format ctors, which are admittedly a nice touch. But the real power of FSArgumentParser is on the command line. It's designed to "just work" in a variety of situations.

### Flag Grouping

It seems natural to us: we like to group flags together. `tar -cvvf`, anyone? FSArgumentParser understands that quite well.

### Equals Signs

Some tools require an equals sign for value assignment (`foo -f=t` works, but `foo -f t` doesn't). FSArgumentParser doesn't mind either formats.

### Multiple Values in a Group

Supposing you have two or more flags that require values, how does that work? FSArgumentParser gives you two ways to work:

        # the long way
    spiffy -i file1 -o file2
        # the lazy way
    spiffy -io file1 file2
    
Personally, I prefer the lazy way. The values are assigned respective to the order of the flags in the group. Note that equals signs are not really logical in argument groups. If you do something like `-cfg=file.txt`, it will assign `file.txt` to `f` (if that's the first flag that takes a value), but it will not do anything fancy, like force that flag to take only one value if it supports multiple values. For that you need to use a barrier.

### Many Values per Argument

New in this version is the ability to have more than one value per time an argument is invoked. You define the number of arguments per invocation as a range, minimum to maximum.

    FSArgumentSignature * files =
        [FSArgumentSignature argumentSignatureWithFormat:@"[-f --files]={1,5}"];
        
And boom, you can specify between one and five files per time you use the `-f` flag. You might think that this could be a little awkward if you have a flag group with two flags that take multiple arguments. Well, it isn't. FSArgumentParser understands "value barriers," which segregate between lists of values. A value barrier is either two dashes (`--`), or any other kind of argument invocation. So, given the following:

    FSArgumentSignature
      *inFiles = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --input-files]={1,5}"],
      *outputFiles = [FSArgumentSignature argumentSignatureWithFormat:@"[-o --output-files]={1,5}"];
    
    // on the command line:
    
    foo -ofv ouput1 output2 output3 -- input1 input2 input3 input4 # use the double-dash to separate
    foo -of ouput1 output2 output3 -v input1 input2 input3 input4 # use the verbose flag to separate
    
See how it "just works" for you?

### Undecorated Arguments

Who here is in love with how the `dd` utility takes its arguments? So perhaps not many, but FSArgumentParser understands that, too.

    foo if=infile of=outfile
    
Is perfectly valid. This can also be used to create "subcommands."

    foo commit -Am "Why are you reinventing git?"
    
### Argument Injection

Wouldn't it be nice to build out a tree of possible arguments, with some arguments which are scanned if and only if a certain argument is present? So thought I, which is why the following invocation could be created like this:
    
    foo commit -Am "Why are you reinventing git?"
    
    // can be accomplished with
    
    FSArgumentSignature * commitSubcommand =
      [FSArgumentSignature argumentSignatureWithFormat:@"[commit]"];
    [commitSubcommand setInjectedSignatures:[NSSet setWithObjects:
      [FSArgumentSignature argumentSignatureWithFormat:@"[-A --all]"],
      [FSArgumentSignature argumentSignatureWithFormat:@"[-m --commit-message]="], nil]];

## Descriptions

By default the `-description` method returns a very simple programmer-friendly text. However, you can use the `descriptionHelper` block property on `FSArgumentSignature`. A different description method which you can call for emitting command-line help will use this. For example:

    FSArgumentSignature * verbose = [FSArgumentSignature argumentSignatureWithFormat:@"[-v --verbose]"];
    FSArgumentSignature * help = [FSArgumentSignature argumentSignatureWithFormat:@"[-h --help]"];

    [verbose setDescriptionHelper:(NSString *)(^)(FSArgumentSignature * currentSignature, NSUInteger indentLevel, NSUInteger terminalWidth) {
        return [@"-v --verbose  Emit more information." fsargs_mutableStringByIndentingToWidth:indentLevel * 2 lineLength:terminalWidth];
    }];
    [help setDescriptionHelper:(NSString *)(^)(FSArgumentSignature * currentSignature, NSUInteger indentLevel, NSUInteger terminalWidth) {
        return [@"-h --help     Show this message." fsargs_mutableStringByIndentingToWidth:indentLevel * 2 lineLength:terminalWidth];
    }];

    FSArgumentPackage * package = 
     [[NSProcessInfo processInfo] fsargs_parseArgumentsWithSignatures:[NSSet setWithObjects:verbose, help, nil]];
    
    if ([package booleanValueOfFlag:help]) {
        struct winsize ws;
        ioctl(0, TIOCGWINSZ, &ws);

        printf("My Really Cool CLI Tool v0.1\n\n");
        printf("%s\n", [[verbose descriptionForHelpWithIndent:2 width:ws.ws_col] UTF8String]);
        printf("%s\n", [[help descriptionForHelpWithIndent:2 width:ws.ws_col] UTF8String]);
        printf("\n(C) 2012 by Your Face. All your base are belong to us.\n");
    }

### Alternatives

* [BRLOptionParser](https://github.com/barrelage/BRLOptionParser) - An
  Objective-C wrapper for `getopt_long`. Looks to be well-constructed.
