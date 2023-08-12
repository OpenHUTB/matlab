function fullFileName = saveFile( ~, designSession, modelHandle, saveAsTag )





R36
~
designSession simulink.multisim.mm.session.Session
modelHandle( 1, 1 )double
saveAsTag( 1, 1 )logical = false
end 

import simulink.multisim.internal.utils.Session.*

studioBlocker = SLM3I.ScopedStudioBlocker;%#ok<NASGU>
modelCloseBlocker = Simulink.internal.AcquireGraph( modelHandle );%#ok<NASGU>

fullFileName = designSession.FullFileName;

if isempty( fullFileName )
fileExtension = "*.mldatx";
fullFileName = getFileNameFromDialog( designSession, fileExtension );
elseif saveAsTag
fullFileName = getFileNameFromDialog( designSession, fullFileName );
end 

if ~isempty( fullFileName )
fileData = getSerializedDataForActiveDesignSuite( modelHandle, designSession );
appName = "Simulink_Multiple_Simulations";
modelName = get_param( modelHandle, "Name" );
appDescription = string( message( "multisim:FileIO:MultipleSimulationsFileDescription", modelName ).getString(  ) );
fileWriter = simulink.simmanager.FileWriter( fileData );
fileWriter.write( fullFileName, appName, appDescription );
simulink.multisim.internal.setSessionDirtyState( modelHandle, false );
simulink.multisim.internal.addFileNameToRecentFilesList( designSession, fullFileName );
simulink.multisim.internal.updateRecentFileListInPrefs( modelHandle, designSession );
designSession.FullFileName = fullFileName;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpykfKlU.p.
% Please follow local copyright laws when handling this file.

