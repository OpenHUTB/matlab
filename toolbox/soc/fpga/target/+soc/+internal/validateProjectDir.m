function validateProjectDir( folderPath )


if isempty( folderPath )
error( message( 'soc:msgs:EmptyPath' ) );
end 


if any( folderPath > 255 )
error( message( 'soc:msgs:NonASCII' ) );
end 


checkSpace = regexp( folderPath, ' ', 'once' );
if ~isempty( checkSpace )
error( message( 'soc:msgs:SpaceInPath' ) );
end 


absFolderPath = soc.internal.makeAbsolutePath( folderPath );


if ispc && strcmp( absFolderPath( 1:2 ), '\\' )
error( message( 'soc:msgs:UNCPath' ) );
end 


checkSpace = regexp( absFolderPath, ' ', 'once' );
if ~isempty( checkSpace )
error( message( 'soc:msgs:SpaceInPath' ) );
end 


if ispc && length( absFolderPath ) > 80
warning( message( 'soc:msgs:LongPath' ) );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmphlt6lk.p.
% Please follow local copyright laws when handling this file.

