function files = getProjectFiles( project )

arguments
project( 1, 1 ) = currentProject(  )
end 

projectFiles = struct( "name", {  }, "files", {  } );
files = i_updateProjectList( [  ], projectFiles, project, project.Name );
end 

function [ projectFiles, projectList ] = i_updateProjectList( projectList, projectFiles, project, projectName )
files = project.Files;
if isempty( files )
paths = string.empty( 1, 0 );
else 
paths = [ files.Path ];
end 

projectFiles( end  + 1 ) = struct( "name", projectName, "files", paths );
projectList = [ projectList, project ];

for ref = project.ProjectReferences
try %#ok<TRYNC>
refProject = ref.Project;
if ~ismember( refProject, projectList )
projectName = string( message( "MATLAB:project:view_unsaved_changes:ReferencedProject", refProject.Name ) );
[ projectFiles, projectList ] = i_updateProjectList( projectList, projectFiles, refProject, projectName );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDLea7b.p.
% Please follow local copyright laws when handling this file.

