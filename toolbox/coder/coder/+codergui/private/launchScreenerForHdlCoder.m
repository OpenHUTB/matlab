function launchScreenerForHdlCoder( files )
arguments
    files{ mustBeA( files, [ "cell", "char", "string", "java.util.Collection" ] ) }
end

if isjava( files )
    files = cellfun( @( f )string( f.getAbsolutePath(  ) ), cell( files.toArray(  ) ) );
else
    files = string( files );
end

opts = coder.internal.ScreenerOptions(  ...
    Environment = coderapp.internal.screener.Environment.LIB,  ...
    Language = coderapp.internal.screener.Language.HDL,  ...
    FixedPointConversion = true );

coder.screener( files, opts );
end

