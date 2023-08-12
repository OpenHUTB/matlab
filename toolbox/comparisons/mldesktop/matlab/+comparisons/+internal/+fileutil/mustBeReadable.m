function mustBeReadable( filePath )



R36
filePath{ mustBeTextScalar }
end 

[ fid, errmsg ] = fopen( filePath, "r" );

if fid ==  - 1
msg = message( 'comparisons:mldesktop:FileReadError', filePath, errmsg );
error( msg );
end 

fclose( fid );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHBIOI_.p.
% Please follow local copyright laws when handling this file.

