function success = openModelWithProjectCheck( modelFile )







R36
modelFile( 1, : )char
end 

if nargout
success = true;
end 

resolvedFile = Simulink.loadsave.resolveFile( modelFile );
if isempty( resolvedFile )
DAStudio.error( 'Simulink:LoadSave:FileNotFound', modelFile );
end 
modelFile = resolvedFile;

[ ~, modelName, modelExt ] = slfileparts( modelFile );
modelFileName = [ modelName, modelExt ];
if ~isvarname( modelName ) || ~ismember( modelExt, { '.mdl', '.slx' } )
fprintf( '%s\n', DAStudio.message( 'Simulink:utility:InvalidModelFileName', modelFileName ) );
DAStudio.error( 'Simulink:utility:InvalidModelFileName', modelFileName );
end 

if bdIsLoaded( modelName )


open_system( modelFile );
return ;
end 

if ~Simulink.ModelFilePrefs.promptToOpenProject(  )

open_system( modelFile );
return ;
end 

[ withinProject, projectRoot ] = matlab.internal.project.util.isUnderProjectRoot( modelFile );
if ~withinProject || any( projectRoot == i_getLoadedProjectRoots(  ) )

open_system( modelFile );
return ;
end 

[ confirm, cancel ] = i_promptToOpenProject( projectRoot, modelFileName );
if cancel

if nargout
success = false;
end 
return ;
end 

if confirm

openProject( projectRoot );
end 


open_system( modelFile );

end 


function roots = i_getLoadedProjectRoots(  )
project = matlab.project.rootProject(  );
if isempty( project )
roots = string.empty( 1, 0 );
else 
roots = [ project.RootFolder, project.listAllProjectReferences.File ];
end 
end 


function [ confirm, cancel ] = i_promptToOpenProject( projectRoot, modelFileName )
try 
project = matlab.internal.project.api.makeProjectAvailable( projectRoot );
projectName = char( project.Name );
catch 
projectName = DAStudio.message( 'sltemplate:Gallery:ConfirmOpenProjectUnknownProject' );
end 

prompt = DAStudio.message( 'sltemplate:Gallery:ConfirmOpenProjectDialogQuestion', projectName, modelFileName );
rootProject = matlab.project.rootProject(  );
if ~isempty( rootProject )
prompt = DAStudio.message( 'sltemplate:Gallery:ConfirmChangeProjectDialogQuestion', prompt, rootProject.Name );
end 

title = DAStudio.message( 'sltemplate:Gallery:ConfirmOpenProjectDialogTitle' );
acceptLabel = DAStudio.message( 'sltemplate:Gallery:ConfirmOpenProjectDialogAcceptProject' );
declineLabel = DAStudio.message( 'sltemplate:Gallery:ConfirmOpenProjectDialogDeclineProject' );
cancelLabel = DAStudio.message( 'sltemplate:Shared:CancelLabel' );

answer = questdlg(  ...
prompt, title,  ...
acceptLabel, declineLabel, cancelLabel,  ...
acceptLabel ...
 );

confirm = strcmp( answer, acceptLabel );
cancel = strcmp( answer, cancelLabel ) || isempty( answer );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpSAmw0l.p.
% Please follow local copyright laws when handling this file.

