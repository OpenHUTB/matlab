




classdef ModelReferenceBrowser < FileReferenceBrowser



properties ( GetAccess = protected, SetAccess = private )
Extensions


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
function obj = ModelReferenceBrowser(  )

exts = slInternal( 'getModelReferenceBrowseExtensions' );
extstr = '';
for i = 1:length( exts )
if ( i > 1 )
extstr = [ extstr, ';' ];%#ok<AGROW>
end 

extstr = [ extstr, '*', exts{ i } ];%#ok<AGROW>
end 
obj.Extensions = extstr;


obj.BrowseFileRefsName = 'Simulink:modelReference:browseMdlRefsName';
obj.SelectedFileNotOnPathQString = 'Simulink:modelReference:selectedMdlNotOnPathQString';
obj.SelectedFilePathIssueTitle = 'Simulink:modelReference:selectedMdlPathIssueTitle';
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

function [ fileName, pathName, filterIndex ] = chooseFile( ~, extstr, dialogTitle, startingLocation )


[ fileName, pathName, filterIndex ] = uigetfile( extstr, dialogTitle, startingLocation );
end 

function postChooseFile( ~, ~, fileName )


if ( ~slInternal( 'hasSimulinkExtension', fileName ) )

DAStudio.error( 'Simulink:modelReference:selectedFileInvalidModel',  ...
fileName )
end 
end 

function [ isLoaded, loadedModelPath ] = findLoadedFile( ~, fileName )


[ ~, modelNameWithoutExt, ~ ] = fileparts( fileName );
loadedModelPath = [  ];



protected = slInternal( 'hasProtectedSimulinkExtension', fileName );

if protected

isLoaded = false;
else 
loadedModel = find_system( 'Type', 'block_diagram', 'Name', modelNameWithoutExt );
isLoaded = ~isempty( loadedModel );
if isLoaded

loadedModelPath = get_param( loadedModel{ 1 }, 'FileName' );
end 
end 
end 

function value = getValueForWidget( ~, fileName )



value = fileName;
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
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpdp7DBM.p.
% Please follow local copyright laws when handling this file.

