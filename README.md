# FSArgumentParser

A short, mostly wrong, but *really useful* tool for rapidly parsing command-line arguments in a declarative manner using Objective-C.

    NSArray * signatures = [NSArray arrayWithObjects:
    
      [FSArgumentSignature argumentSignatureWithNames:
        [NSArray arrayWithObjects:@"-f", @"--force", nil]      flag:YES required:NO  multipleAllowed:YES],
      [FSArgumentSignature argumentSignatureWithNames:
        [NSArray arrayWithObjects:@"-s", @"--soft", nil]       flag:YES required:NO  multipleAllowed:NO ],
      [FSArgumentSignature argumentSignatureWithNames:
        [NSArray arrayWithObject:@"--output-file"]             flag:NO  required:YES multipleAllowed:NO ],
      [FSArgumentSignature argumentSignatureWithNames:
        [NSArray arrayWithObjects:@"--input-file", @"-i", nil] flag:NO required:YES  multipleAllowed:YES],
      
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
    // how much force is set? eg. -f -f will yield 2. Ain't that spiffy?
    
    NSString * outputFileName = [arguments.namedArguments objectForKey:[signatures objectAtIndex:2]];
    // because multiple is not allowed, this is guaranteed to be either nil or a single string. Because it's
    // required, you can be guaranteed this will not be nil.
    
    NSArray * inputFiles = [arguments.namedArguments objectForKey:[signatures objectAtIndex:3]];
    // because multiple is allowed, this is always going to be an array, even if there's only one object.
    
    NSArray * otherArgs = arguments.unnamedArguments; // these are all the other things that aren't flags and
    // aren't named by a flag. If there's something flag-like in the command-line arguments which isn't a known
    // signature, it'll end up here, too.
    
Because it's declarative, the objective is to declare your arguments characteristics in as few places as possible. It also passes some fairly decent errors at you when it dies.