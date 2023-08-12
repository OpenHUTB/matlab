function exportHelper( fig, option )

name = getFigureName( fig );
filter = { '*.jpg;*.jpeg', 'JPEG Files (*.jpg, *.jpeg)'; ...
'*.png', 'PNG Files (*.png)'; ...
'*.tif;*.tiff', 'TIFF Files(*.tif, *.tiff)'; ...
'*.pdf', 'PDF Files (*.pdf)'; ...
'*.eps', 'Encapsulated PostScript (*.eps)' };
title = 'Export Figure';



if ~isempty( option )
filter = { [ '*.', option ], [ upper( option ), ' Files (*.', option, ')' ] };
title = [ 'Export ', upper( option ), ' File' ];
end 

[ file, path ] = uiputfile( filter, title, name );


if ~isequal( file, 0 ) && ~isequal( path, 0 )
exportgraphics( fig, [ path, file ] );
end 

end 

function name = getFigureName( fig )
name = fig.Name;

if isempty( name )
name = fig.Tag;
end 

if isempty( name )
name = [ 'Figure_', num2str( fig.Number ) ];
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpWFEuiZ.p.
% Please follow local copyright laws when handling this file.

