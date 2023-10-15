function verifyHelper( modelObj, inputArgs, options )

arguments
    modelObj( 1, 1 )SimBiology.Model
end
arguments( Repeating )

    inputArgs
end
arguments
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

