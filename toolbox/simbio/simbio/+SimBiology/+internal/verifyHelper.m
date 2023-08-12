function verifyHelper( modelObj, inputArgs, options )




































R36
modelObj( 1, 1 )SimBiology.Model
end 
R36( Repeating )

inputArgs
end 
R36
options.SendAllMessages( 1, 1 )logical = false
options.RequireObservableDependencies( 1, 1 )logical = true
end 

if options.SendAllMessages
modelObj.CompileNeeded = true;
end 

[ cs, variants, doses ] = sbiogate( "compileargchk", modelObj, inputArgs{ : } );
accelerateFlag = false;
try 
SimBiology.internal.compile( modelObj, cs, variants, doses, accelerateFlag,  ...
options.RequireObservableDependencies );
catch exception
throw( exception );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFkvR2P.p.
% Please follow local copyright laws when handling this file.

