function writeToFile( filename, contents )



R36
filename{ mustBeTextScalar }
contents{ mustBeTextScalar }
end 

[ fid, errmsg ] = fopen( filename, "w", "n", "UTF-8" );

if fid ==  - 1
msg = message( 'comparisons:mldesktop:FileWriteError', filename, errmsg );
error( msg );
end 

cleanUp = onCleanup( @(  )fclose( fid ) );

fprintf( fid, "%s", contents );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6cdgCv.p.
% Please follow local copyright laws when handling this file.

