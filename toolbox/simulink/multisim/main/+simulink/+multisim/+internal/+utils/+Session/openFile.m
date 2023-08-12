function openFile( sessionDataModel, designSession, modelHandle, fullFileName, fileExtension )





R36
sessionDataModel( 1, 1 )mf.zero.Model
designSession simulink.multisim.mm.session.Session
modelHandle( 1, 1 )double
fullFileName( 1, 1 )string = "";
fileExtension( 1, 1 )string = "*.mldatx"
end 

import simulink.multisim.internal.utils.Session.*

if designSession.IsDirty
choice = simulink.multisim.internal.confirmSaveBeforeClose( modelHandle );
switch choice
case "yes"
savedFileName = simulink.multisim.internal.utils.Session.saveFile( sessionDataModel, designSession, modelHandle );
if isempty( savedFileName )
return ;
end 
case ""
return ;
end 
end 

if fullFileName == ""
[ fileName, pathName ] = uigetfile( fileExtension );
if ( fileName ~= 0 )
fullFileName = fullfile( pathName, fileName );
end 
end 

if fullFileName ~= ""
currentModelName = get_param( modelHandle, "Name" );
try 
fileReader = simulink.simmanager.FileReader( fullFileName );
catch ME
dvStageCleanup = createDVStage( currentModelName );
sldiagviewer.reportError( ME );
return ;
end 

[ ~, splitFileName, extension ] = fileparts( fullFileName );
warnFileName = strcat( splitFileName, extension );

fileMATLABRelease = fileReader.getMATLABRelease(  );
fileSimulinkVersion = simulink_version( fileMATLABRelease );
if ( fileSimulinkVersion.version ==  - 1 )
dvStageCleanup = createDVStage( currentModelName );
sldiagviewer.reportError( message( "multisim:SetupGUI:FileFromNewerRelease",  ...
warnFileName, string( fileMATLABRelease ) ).getString(  ) );
return ;
end 

oldModelName = fileReader.getPart( "/ModelName", false );

if ~strcmp( oldModelName, currentModelName )
quest = message( "multisim:SetupGUI:FileFromDifferentModelMessage", warnFileName, oldModelName ).getString;
yes = message( "multisim:SetupGUI:DialogYes" ).getString;
no = message( "multisim:SetupGUI:DialogNo" ).getString;
title = message( "multisim:SetupGUI:FileFromDifferentModelTitle" ).getString;
choice = questdlg( quest, title, yes, no, no );
if ~strcmp( choice, yes )
return ;
end 
end 

dataModelString = fileReader.getPart( "/DesignSuite.xml", true );

parser = mf.zero.io.XmlParser;
designSuite = parser.parseString( dataModelString );
designSuite.FeatureFaults = simulink.multisim.internal.isFaultInjectionAvailable(  );
designSuite.IsParameterCombinationsEnabled = slfeature( "ParameterCombinationsInRunAllUI" ) ~= 0;
designSuite.IsPreviewEnabled = slfeature( "MultipleSimulationsPreview" ) ~= 0;
designSuiteDataModel = parser.Model;

setDesignSuiteBdData( modelHandle, designSession, designSuiteDataModel, designSuite );
setActiveDesignSuite( sessionDataModel, designSession, designSuiteDataModel.UUID );
simulink.multisim.internal.setSessionDirtyState( modelHandle, false );
designSuiteDataModel.addObservingListener( @( ~, ~ )simulink.multisim.internal.setSessionDirtyState( modelHandle, true ) );

simulink.multisim.internal.addFileNameToRecentFilesList( designSession, fullFileName );
simulink.multisim.internal.updateRecentFileListInPrefs( modelHandle, designSession );

simulink.multisim.internal.setRunAllContext( modelHandle );

designSession.FullFileName = fullFileName;
end 
end 

function dvStageCleanup = createDVStage( currentModelName )
dvStageName = message( "multisim:SetupGUI:DVMultiSimStageName" ).getString(  );
dvStage = sldiagviewer.createStage( dvStageName, "ModelName", currentModelName );
dvStageCleanup = onCleanup( @(  )delete( dvStage ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpWyyN0g.p.
% Please follow local copyright laws when handling this file.

