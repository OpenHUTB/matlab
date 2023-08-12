function addFileFilters( files )






R36
files( 1, : )cell
end 
cellfun( @( file )iAddFile( file ), files );
end 

function iAddFile( file )
if ~isempty( file )
filePath = which( file );



if ~any( contains( callstats( 'pffilter' ), filePath ) )
callstats( 'pffilter', 'add', filePath );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1nN_r2.p.
% Please follow local copyright laws when handling this file.

