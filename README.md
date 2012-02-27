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
    mytool --if file1 --of file2
          # the shorter way
    mytool -i file1 -o file2
          # the spiffy way
    mytool -io file1 file2
    
So the ordering of short flags determines the interpretation of the arguments. So `io` is the opposite of `oi`, etc. ¿Comprendé?

## Descriptions

You can also declare your flag descriptions inline:

    [FSArgumentSignature argumentSignatureAsFlag:@"
      longNames:@"verbose"
      multipleAllowed:YES
      description:@"-v --verbose much speaking to annoy people."]
    
From there, it's pretty easy to emit something:

    [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        printf("%s\n", [[obj descriptionWithLocale:nil indent:1] UTF8String]);
    }];

You can also use a block or delegate callback if you want a different way to specify description messages instead of right there as a straight string.

The description messages are formatted to indent if you like (by using `descriptionWithLocale:indent:`) and they try to detect the current terminal width and then word-wrap while keeping the indent. It's pretty cool, so you should try making a really long description and seeing what it does.

## Why bother?

It's a fair sight easier than parsing args by hand. This can handle a lot of the annoying things for you. For instance:

* Is a required argument missing?
* Is there a value missing that should be attached to a known argument?

## So?

Overall it's just total awesomeness, saving you time and helping you declare your arguments in a single place.