function writeToFile( filename, contents )

arguments
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


