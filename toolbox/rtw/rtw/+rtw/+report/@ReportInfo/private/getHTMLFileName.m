

function htmlFileName = getHTMLFileName( filename )
%#ok<DEFNU>
[ ~, fname, ext ] = fileparts( filename );
htmlFileName = [ fname, '_', ext( 2:end  ), '.html' ];

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7DZBBv.p.
% Please follow local copyright laws when handling this file.

