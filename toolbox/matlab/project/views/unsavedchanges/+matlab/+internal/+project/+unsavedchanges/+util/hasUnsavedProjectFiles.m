function result = hasUnsavedProjectFiles( project )




R36
project( 1, 1 ) = currentProject(  )
end 

files = matlab.internal.project.unsavedchanges.getLoadedFiles( "Unsaved" );

unsavedFiles = matlab.internal.project.unsavedchanges.filter.unsavedProjectFiles( files, project );
result = ~isempty( unsavedFiles );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwxkFZD.p.
% Please follow local copyright laws when handling this file.

