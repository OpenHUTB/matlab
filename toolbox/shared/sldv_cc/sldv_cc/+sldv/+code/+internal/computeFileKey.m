function fileKey = computeFileKey( file )

arguments
    file( 1, 1 )internal.cxxfe.instrum.File
end

[ ~, fname, fext ] = fileparts( file.shortPath );
structuralChecksum = join( string( dec2hex( file.structuralChecksum.toArray(  ) ) ), "" );
fileKey = sprintf( '%s%s-%s', fname, fext, structuralChecksum );

