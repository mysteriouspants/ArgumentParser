# FSArgumentParser

A short, awesome, and *really useful* tool for rapidly parsing command-line arguments in a declarative manner using Objective-C.

    NSArray * signatures = [NSArray arrayWithObjects:
    
      [FSArgumentSignature argumentSignatureAsFlag:@"f" longNames:@"force" multipleAllowed:YES],
      [FSArgumentSignature argumentSignatureAsFlag:@"s" longNames:@"soft" multipleAllowed:NO],
      [FSArgumentSignature argumentSignatureAsNamedArgument:nil
        longNames:@"output-file" required:YES multipleAllowed:NO],
      [FSArgumentSignature argumentSignatureAsNamedArgument:@"i"
        longNames:@"input-file" required:YES multipleAllowed:YES],
      
      nil];
      
    NSError * error;
    FSArgumentPackage * arguments = [FSArgumentParser parseArguments:[[NSProcessInfo processInfo] arguments] 
                                                      withSignatures:signatures
                                                               error:&error];
    
    if (error) {
      NSLog(@"Error! %@", error);
      exit(-1);
    }
    
    // arguments now has all the information you could want!
    
    BOOL forceFlag = [[arguments.flags objectForKey:[signatures objectAtIndex:0]] boolValue]; // do I have the
    // force flag set?
    
    NSUInteger howMuchForce = [[arguments.flags objectForKey:[signatures objectAtIndex:0]] unsignedIntegerValue];
    // how much force is set? eg. -ff will yield 2. Ain't that spiffy?
    
    NSString * outputFileName = [arguments.namedArguments objectForKey:[signatures objectAtIndex:2]];
    // because multiple is not allowed, this is guaranteed to be either nil or a single string. Because it's
    // required, you can be guaranteed this will not be nil.
    
    NSArray * inputFiles = [arguments.namedArguments objectForKey:[signatures objectAtIndex:3]];
    // because multiple is allowed, this is always going to be an array, even if there's only one object.
    
    NSArray * otherArgs = arguments.unnamedArguments; // these are all the other things that aren't flags and
    // aren't named by a flag. If there's something flag-like in the command-line arguments which isn't a known
    // signature, it'll end up here, too.
    
Because it's declarative, the objective is to declare your arguments characteristics in as few places as possible. It also passes some fairly decent errors at you when it dies.

## Spiffy

I've spent some time to make this actually pretty darn spiffy. For example, how are multiple named arguments handled when they're short names? For example:

    [FSArgumentSignature argumentSignatureAsNamedArgument:@"i" longNames:@"if" required:YES multipleAllowed:NO],
    [FSArgumentSignature argumentSignatureAsNamedArgument:@"o" longNames:@"of" required:YES multipleAllowed:NO],
    
Now, I have several ways to work with this:

          # the long way
    spiffy --if file1 --of file2
          # the shorter way
    spiffy -i file1 -o file2
          # the spiffy way
    spiffy -io file1 file2
    
So the ordering of short flags determines the interpretation of the arguments. So `io` is the opposite of `oi`, etc. ¿Comprendé?

Look at the file `example/spiffy.m` for an example, and try running it with those arguments. You can build the examples using the Rakefile.

## Descriptions

You can also declare your flag descriptions inline:

    [FSArgumentSignature argumentSignatureAsFlag:@"v"
      longNames:@"verbose"
      multipleAllowed:YES
      description:@"-v --verbose much speaking to annoy people."]
    
From there, it's pretty easy to emit something:

    [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        printf("%s\n", [[obj descriptionWithLocale:nil indent:1] UTF8String]);
    }];

You can also use a block or delegate callback if you want a different way to specify description messages instead of right there as a straight string.

The description messages are formatted to indent if you like (by using `descriptionWithLocale:indent:`) and they try to detect the current terminal width and then word-wrap while keeping the indent. It's pretty cool, so you should try making a really long description and seeing what it does.

Look at the file `example/desc.m` for a demonstration; the file `example/long-desc.m` shows how it detects the terminal width.You can build the examples using the Rakefile.

## Why bother?

It's a fair sight easier than parsing args by hand. This can handle a lot of the annoying things for you. For instance:

* Is a required argument missing?
* Is there a value missing that should be attached to a known argument?

## So?

Overall it's just total awesomeness, saving you time and helping you declare your arguments in a single place.

## Examples? We got examples!

If you have the following:

* Xcode 4.3 with command-line tools installed
* Ruby and Rake (I suggest RVM and RBX)
* The Rake gem (comes with RBX)

Then you're armed and fully operational to start building the example code!

    > rake all
    clang FSArgumentPackage.m -DDEBUG -std=c99 -fobjc-arc -I ./ -g -c -o FSArgumentPackage.o
    clang FSArgumentParser.m -DDEBUG -std=c99 -fobjc-arc -I ./ -g -c -o FSArgumentParser.o
    clang FSArgumentSignature.m -DDEBUG -std=c99 -fobjc-arc -I ./ -g -c -o FSArgumentSignature.o
    clang example/desc.m -DDEBUG -std=c99 -fobjc-arc -I ./ -g -c -o example/desc.o
    clang -framework Foundation FSArgumentPackage.o FSArgumentParser.o FSArgumentSignature.o example/desc.o -o bin/desc
    clang example/long-desc.m -DDEBUG -std=c99 -fobjc-arc -I ./ -g -c -o example/long-desc.o
    clang -framework Foundation FSArgumentPackage.o FSArgumentParser.o FSArgumentSignature.o example/long-desc.o -o bin/long-desc
    clang example/spiffy.m -DDEBUG -std=c99 -fobjc-arc -I ./ -g -c -o example/spiffy.o
    clang -framework Foundation FSArgumentPackage.o FSArgumentParser.o FSArgumentSignature.o example/spiffy.o -o bin/spiffy
    > bin/desc -h
    Example program with help flag!
    
        Flag responding to -h and --help; required:NO multipleAllowed:NO
        Argument responding to -o and --out-file; required:NO multipleAllowed:YES
    > bin/long-desc -h
    Example program with help flag!
    
        Flag responding to -h and --help; required:NO multipleAllowed:NO
        -o file --out-file file (not required) specify zero or more output files. I'
        m not really sure why you'd want to pipe the output to more than one file, b
        ut the main point of this is to show how the program can wrap really long li
        nes without screwing up the indentation.
    > bin/spiffy -h
    Example program with help flag!
    
        Flag responding to -h and --help; required:NO multipleAllowed:NO
        Argument responding to -i and --if; required:YES multipleAllowed:NO
        Argument responding to -o and --of; required:YES multipleAllowed:NO
    
    Oh, PS, there was an error: {
        missingTheseSignatures = "{(\n        Argument responding to -i and --if; required:YES multipleAllowed:NO,\n        Argument responding to -o and --of; required:YES multipleAllowed:NO\n)}";
    }
    > bin/spiffy -io file0 file1
    Example program:
      Input File: file0
      OutputFile: file1

Kinda neat, no?

### One other note

I'd like to point out that the output of `spiffy -h` demonstrates how you still get an argument package back when you're missing required flags. This is a slight modification designed to allow you to detect help flags. So, if you wanted to have different error handling code that doesn't just spit out the help stuff.