



classdef SubsystemReferenceBrowser < FileReferenceBrowser



properties ( GetAccess = protected, SetAccess = private )
OpenFile
DefaultFileName
Extensions
DlgHandle
HiddenFileNameTag
HiddenFileDirTag


BrowseFileRefsName
SelectedFileNotOnPathQString
SelectedFilePathIssueTitle
SelectedFileNotOnPathAddCurrentSession
SelectedFileNotOnPathDoNotAdd
SelectedFileNotOnPathCancel
SelectedFileExistsOnPathQString

SelectedFileHasLowerPrecedence
SelectedFileHasLowerPrecedenceDirty
SelectedFileHasHigherPrecedenceTemporarily
SelectedFilePrecedenceIssueTitle
SelectedFilePrecedenceIssueContinue
SelectedFilePrecedenceIssueCancel
SelectedFileIsLoadedWithMultipleFilesOnPath
end 

methods 


function obj = SubsystemReferenceBrowser( openFile, defaultFileName,  ...
dlgHandle, hiddenFileNameTag, hiddenFileDirTag )
obj.OpenFile = openFile;
obj.DefaultFileName = defaultFileName;

file_format = get_param( 0, 'ModelFileFormat' );
if strcmp( file_format, 'slx' )
obj.Extensions = { '*.slx';'*.mdl' };
else 
obj.Extensions = { '*.mdl';'*.slx' };
end 

obj.DlgHandle = dlgHandle;
obj.HiddenFileNameTag = hiddenFileNameTag;
obj.HiddenFileDirTag = hiddenFileDirTag;


if openFile
obj.BrowseFileRefsName = 'Simulink:SubsystemReference:BrowseSubsystemFile';
else 
obj.BrowseFileRefsName = 'Simulink:SubsystemReference:SaveSubsystemFile';
end 
obj.SelectedFileNotOnPathQString = 'Simulink:SubsystemReference:SelectedSubsystemNotOnPath';
obj.SelectedFilePathIssueTitle = 'Simulink:SubsystemReference:SelectedSubsystemPathIssueTitle';
obj.SelectedFileNotOnPathAddCurrentSession = 'Simulink:modelReference:selectedMdlNotOnPathAddCurrentSession';
obj.SelectedFileNotOnPathDoNotAdd = 'Simulink:modelReference:selectedMdlNotOnPathDoNotAdd';
obj.SelectedFileNotOnPathCancel = 'Simulink:modelReference:selectedMdlNotOnPathCancel';
obj.SelectedFileExistsOnPathQString = 'Simulink:modelReference:selectedMdlExistsOnPathQString';

obj.SelectedFileHasLowerPrecedence = 'Simulink:modelReference:selectedModelHasLowerPrecedence';
obj.SelectedFileHasLowerPrecedenceDirty = 'Simulink:modelReference:selectedModelHasLowerPrecedenceDirty';
obj.SelectedFileHasHigherPrecedenceTemporarily = 'Simulink:modelReference:selectedModelHasHigherPrecedenceTemporarily';
obj.SelectedFilePrecedenceIssueTitle = 'Simulink:modelReference:selectedMdlPrecedenceIssueTitle';
obj.SelectedFilePrecedenceIssueContinue = 'Simulink:modelReference:selectedMdlPrecedenceIssueContinue';
obj.SelectedFilePrecedenceIssueCancel = 'Simulink:modelReference:selectedMdlPrecedenceIssueCancel';
obj.SelectedFileIsLoadedWithMultipleFilesOnPath = 'Simulink:modelReference:selectedFileIsLoadedWithMultipleFilesOnPath';
end 
end 

methods ( Access = protected )
function startingLocation = startingLocationForBrowseButton( ~, currentModel )
startingLocation = startingLocationForModelBrowseButton( currentModel );
end 



function [ fileName, pathName, filterIndex ] = chooseFile( this, extstr, dialogTitle, startingLocation )
if ( this.OpenFile )
[ fileName, pathName, filterIndex ] = uigetfile( extstr, dialogTitle, startingLocation );
else 
[ fileName, pathName, filterIndex ] = uiputfile( extstr,  ...
dialogTitle, [ startingLocation, '/', this.DefaultFileName, '.slx' ] );

end 
end 


function postChooseFile( this, pathName, fileName )
[ ~, ~, ext ] = fileparts( fileName );

if ( ~( ( strcmpi( ext, '.mdl' ) ) ||  ...
( strcmpi( ext, '.slx' ) ) ) )

DAStudio.error( 'Simulink:SubsystemReference:InvalidFileSelected',  ...
fileName )
end 

if ( ~this.OpenFile )
this.DlgHandle.setWidgetValue( this.HiddenFileDirTag, pathName );
end 
end 


function [ isLoaded, loadedModelPath ] = findLoadedFile( ~, fileName )
[ isLoaded, loadedModelPath ] = SRDialogHelper.findLoadedFile( fileName );
end 


function value = getValueForWidget( this, fileName )

[ ~, modelNameWithoutExt, ~ ] = fileparts( fileName );
value = modelNameWithoutExt;

if ( ~this.OpenFile )
this.DlgHandle.setWidgetValue( this.HiddenFileNameTag, fileName );
end 
end 

function files = getFilesOnPathMatchingSelectedFile( ~, fileName )
[ ~, modelNameWithoutExt ] = fileparts( fileName );



filePaths = which( '-all', modelNameWithoutExt );

if slInternal( 'hasUnprotectedSimulinkExtension', fileName )
filterFcn = 'hasUnprotectedSimulinkExtension';
else 
filterFcn = 'hasProtectedSimulinkExtension';
end 

simulinkFiles = cellfun( @( x )slInternal( filterFcn, x ), filePaths );
files = filePaths( simulinkFiles );
end 









function cancelOperation = resolvePathIssueForAUniqueFile( this, pathName, fileName )

existingFile = isfile( [ pathName, fileName ] );
if existingFile
cancelOperation =  ...
resolvePathIssueForAUniqueFile@FileReferenceBrowser( this, pathName, fileName );
return ;
end 






parentDir = fileparts( pathName );




fileIsInPath = ismember( parentDir, strsplit( path, pathsep ) ) ||  ...
strcmp( parentDir, pwd );
if fileIsInPath
cancelOperation = false;
return ;
end 


cancelOperation =  ...
resolvePathIssueForAUniqueFile@FileReferenceBrowser( this, pathName, fileName );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSbL7bJ.p.
% Please follow local copyright laws when handling this file.

