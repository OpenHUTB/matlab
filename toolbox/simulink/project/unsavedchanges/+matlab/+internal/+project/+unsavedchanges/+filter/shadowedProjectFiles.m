function shadowedFiles = shadowedProjectFiles( loadedFiles, project )




R36
loadedFiles matlab.internal.project.unsavedchanges.LoadedFile
project = currentProject(  )
end 

shadowedFiles = struct( "name", {  }, "files", {  } );
if isempty( loadedFiles )
return ;
end 

fileGroups = matlab.internal.project.unsavedchanges.util.getProjectFiles( project );

loadedFilePaths = [ loadedFiles.Path ];
[ ~, loadedFileNames ] = fileparts( loadedFilePaths );

for n = 1:length( fileGroups )

projectFiles = fileGroups( n ).files;
[ ~, idx, ~ ] = intersect( projectFiles, loadedFilePaths );
projectFiles( idx ) = [  ];


[ ~, projectFileNames, ext ] = fileparts( projectFiles );
modelIdx = ismember( ext, [ ".slx", ".mdl" ] );
projectModels = projectFileNames( modelIdx );
[ ~, ~, matchIdx ] = intersect( projectModels, loadedFileNames );
if ~isempty( matchIdx )
loadedModels = loadedFiles( matchIdx );
shadowedFiles( end  + 1 ) = struct( "name", fileGroups( n ).name, "files", loadedModels );%#ok<AGROW>
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYlaZ45.p.
% Please follow local copyright laws when handling this file.

