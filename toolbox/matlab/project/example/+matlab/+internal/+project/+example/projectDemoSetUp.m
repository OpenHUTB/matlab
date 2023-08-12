function [ exampleFolder, repositoryPath, projectRoot ] = projectDemoSetUp( archivedProject, exampleFolderRoot, cmSystem )


















R36
archivedProject( 1, : )char{ mustBeFile }
exampleFolderRoot( 1, : )char = i_getDefaultExampleFolderRoot(  )
cmSystem = 'git'
end 

repositoryPath = [  ];




if islogical( cmSystem )

if cmSystem

cmSystem = 'git';
else 
cmSystem = '';
end 
end 
useCM = ~isempty( cmSystem );

if matlab.ui.internal.desktop.isMOTW && strcmpi( cmSystem, 'svn' )
error( message( "shared_cmlink:core:SVNDisabledInMATLABOnline" ).string(  ) );
end 

[ ~, exampleFolderName, ~ ] = fileparts( archivedProject );

if isempty( exampleFolderRoot )
exampleFolderRoot = i_getDefaultExampleFolderRoot(  );
end 

[ exampleFolder, repositoryFolder ] = i_exampleFolder( exampleFolderRoot, exampleFolderName, useCM );

i_create_folder( exampleFolder );

if useCM
try 
i_create_folder( repositoryFolder );
repositoryPath = matlab.internal.project.example.createWorkingCopy( repositoryFolder, exampleFolder, cmSystem );
setupSuccess = true;
catch E
warning( E.identifier, '%s', E.message )
setupSuccess = false;
end 
end 

projectRoot = matlab.internal.project.example.extractExampleArchive( archivedProject, exampleFolder );

if useCM && setupSuccess
matlab.internal.project.example.addAndCommitAllFiles( exampleFolder, 'Initial check-in' );
end 

end 

function exampleFolderRoot = i_getDefaultExampleFolderRoot(  )

if matlab.ui.internal.desktop.isMOTW
workFolder = matlab.internal.examples.getExamplesDir(  );


exampleFolderRoot = fullfile( workFolder, 'projects' );
else 

workFolder = matlab.internal.project.util.getDefaultProjectFolder(  );

exampleFolderRoot = fullfile( workFolder, 'examples' );
end 

end 

function [ exampleFolder, repositoryFolder ] = i_exampleFolder( exampleFolderRoot, exampleFolderName, useCM )



import matlab.internal.project.util.generateFolderGroupNames;

if useCM
repositoryFolderRoot = fullfile( exampleFolderRoot, 'repositories' );

[ exampleFolder, repositoryFolder ] = generateFolderGroupNames(  ...
{ exampleFolderRoot, repositoryFolderRoot },  ...
exampleFolderName ...
 );
else 
repositoryFolder = '';

exampleFolder = generateFolderGroupNames(  ...
{ exampleFolderRoot },  ...
exampleFolderName ...
 );
end 

end 

function i_create_folder( folder )
if ~isfolder( folder )
mkdir( folder );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBpNa6O.p.
% Please follow local copyright laws when handling this file.

