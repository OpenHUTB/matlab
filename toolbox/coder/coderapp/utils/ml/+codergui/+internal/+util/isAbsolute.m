


function result = isAbsolute( file )
R36
file{ mustBeText }
end 

if ispc(  )
file = cellstr( strrep( file, '/', '\' ) );
result = ~cellfun( 'isempty', regexp( file, '^[a-zA-Z]:\\', 'once' ) ) | startsWith( file, '\\' );
else 
result = startsWith( file, '/' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6cWoKV.p.
% Please follow local copyright laws when handling this file.

