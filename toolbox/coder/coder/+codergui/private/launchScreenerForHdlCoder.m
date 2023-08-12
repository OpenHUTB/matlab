


function launchScreenerForHdlCoder( files )
R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmp1JyfIb.p.
% Please follow local copyright laws when handling this file.

