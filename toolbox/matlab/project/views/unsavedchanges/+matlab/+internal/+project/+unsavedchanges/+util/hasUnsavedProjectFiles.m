function result = hasUnsavedProjectFiles( project )

arguments
project( 1, 1 ) = currentProject(  )
end 

files = matlab.internal.project.unsavedchanges.getLoadedFiles( "Unsaved" );

unsavedFiles = matlab.internal.project.unsavedchanges.filter.unsavedProjectFiles( files, project );
result = ~isempty( unsavedFiles );
end 

