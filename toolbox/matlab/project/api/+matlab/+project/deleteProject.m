function deleteProject( projectLocation )




R36
projectLocation( 1, 1 )string{ mustBeFolder }
end 

projectLocation = matlab.internal.project.api.makePathAbsoluteAndNormalize( projectLocation );

loadedProjects = matlab.project.currentProject(  );
if ~isempty( loadedProjects ) && i_isInReferenceHierarchy( loadedProjects, projectLocation )
error( message( 'MATLAB:project:management:DeleteFailLoaded' ) );
end 

matlab.internal.project.api.deleteProject( projectLocation );
end 

function isInReferenceHierarchy = i_isInReferenceHierarchy( topLevelProject, location )
refs = topLevelProject.listAllProjectReferences;
allRoots = [ topLevelProject.RootFolder, refs.File ];

ignoreCase = ispc;

if ignoreCase
isInReferenceHierarchy = any( strcmpi( location, allRoots ) );
else 
isInReferenceHierarchy = any( strcmp( location, allRoots ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQHuYOG.p.
% Please follow local copyright laws when handling this file.

