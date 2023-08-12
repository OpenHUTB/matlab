function slddShowChanges( dictFileName )

try 
path = comparisons.internal.resolvePath( dictFileName );
fs = comparisons.internal.makeFileSource( path );
comparisons.internal.gui.compareInDesktop( fs, fs );
catch E
error( E.message );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpaDj9ml.p.
% Please follow local copyright laws when handling this file.

