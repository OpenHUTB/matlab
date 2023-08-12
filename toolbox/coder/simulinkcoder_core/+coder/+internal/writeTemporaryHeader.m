function writeTemporaryHeader( wrapperHeader, header, defines )

fid = fopen( wrapperHeader, 'w' );
cleanupFid = onCleanup( @(  )fclose( fid ) );
fprintf( fid, '/* With loadlibrary, must use definitions from tmwtypes.h */\n' );
fprintf( fid, '#include <tmwtypes.h>\n\n' );
fprintf( fid, '/* Suppress rtwtypes.h definitions due to prior include of tmwtypes.h */\n' );
fprintf( fid, '#define RTWTYPES_H\n' );

for index = length( defines ): - 1:1
fprintf( fid, '%s\n', defines( index ) );
end 

fprintf( fid, '#include "%s"\n', header );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpin9r0i.p.
% Please follow local copyright laws when handling this file.

