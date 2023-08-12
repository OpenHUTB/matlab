



function fileKey = computeFileKey( file )

R36
file( 1, 1 )internal.cxxfe.instrum.File
end 

[ ~, fname, fext ] = fileparts( file.shortPath );
structuralChecksum = join( string( dec2hex( file.structuralChecksum.toArray(  ) ) ), "" );
fileKey = sprintf( '%s%s-%s', fname, fext, structuralChecksum );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPncu5N.p.
% Please follow local copyright laws when handling this file.

