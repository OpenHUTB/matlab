function out = getHTMLFileName( filename )
[ ~, fname, ext ] = fileparts( filename );
out = [ fname, '_', ext( 2:end  ), '.html' ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPjmuvT.p.
% Please follow local copyright laws when handling this file.

