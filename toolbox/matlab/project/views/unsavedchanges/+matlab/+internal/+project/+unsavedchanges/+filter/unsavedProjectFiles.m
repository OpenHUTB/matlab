function unsavedFiles = unsavedProjectFiles( loadedFiles, project )

arguments
    loadedFiles( 1, : )matlab.internal.project.unsavedchanges.LoadedFile
    project( 1, 1 ) = currentProject(  )
end

import matlab.internal.project.unsavedchanges.Property;
matches = arrayfun( @( file )file.hasProperty( Property.Unsaved ), loadedFiles );
allUnsavedFiles = loadedFiles( matches );

unsavedFiles = struct( "name", {  }, "files", {  } );
if isempty( allUnsavedFiles )
    return ;
end

fileGroups = matlab.internal.project.unsavedchanges.util.getProjectFiles( project );
unsavedFilePaths = [ allUnsavedFiles.Path ];

for n = 1:length( fileGroups )
    [ ~, idx, ~ ] = intersect( unsavedFilePaths, fileGroups( n ).files );
    if ~isempty( idx )
        matchingFiles = allUnsavedFiles( idx );
        unsavedFiles( end  + 1 ) = struct( "name", fileGroups( n ).name, "files", matchingFiles );%#ok<AGROW>
    end
end
end

