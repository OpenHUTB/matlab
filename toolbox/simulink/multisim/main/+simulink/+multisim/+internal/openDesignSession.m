function openDesignSession( studio )





R36
studio( 1, 1 )DAS.Studio
end 

modelHandle = studio.App.blockDiagramHandle;

dataId = simulink.multisim.internal.blockDiagramAssociatedDataId(  );

if ~Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, dataId )
Simulink.BlockDiagramAssociatedData.register( modelHandle, dataId, "any" );
end 

bdData = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );
if isempty( bdData )

bdData = createBlockDiagramAssociatedData( modelHandle );
Simulink.BlockDiagramAssociatedData.set( modelHandle, dataId, bdData );
addListenerForModelCloseForSavingSession( modelHandle, bdData.SessionDataModel );
addListenerForModelNameChangeForUpdatingDesignStudies( modelHandle );
end 




url = simulink.multisim.internal.createDesignSessionURL( bdData.SessionDataModel.UUID );
windowTitle = string( message( "multisim:SetupGUI:WindowTitle" ).getString(  ) );
simulink.multisim.internal.createDockedWebBrowserInStudio( studio, url, dataId, windowTitle );
simulink.multisim.internal.updateBrowserWindowTitle( modelHandle, bdData.Session.IsDirty, bdData.Session.FullFileName );
simulink.multisim.internal.setRunAllContext( modelHandle );
end 

function bdData = createBlockDiagramAssociatedData( modelHandle )
sessionDataModel = mf.zero.Model;
session = simulink.multisim.mm.session.Session( sessionDataModel );
session.ModelHandle = double( modelHandle );
session.FileSeparator = filesep;
simulink.multisim.internal.setRecentFilesFromPrefs( modelHandle, session );

sessionDataModelSynchronizer = simulink.multisim.internal.DataModelSynchronizer( sessionDataModel );

sessionCommandChannelName = sessionDataModelSynchronizer.ChannelName + "/command";
session.CommandChannelName = sessionCommandChannelName;
sessionCommandDispatcher = simulink.multisim.internal.CommandDispatcher( sessionCommandChannelName, sessionDataModel, modelHandle );

designSuiteMap = containers.Map( "KeyType", "char", "ValueType", "any" );

bdData = struct( "SessionDataModel", sessionDataModel,  ...
"Session", session,  ...
"SessionDataModelSynchronizer", sessionDataModelSynchronizer,  ...
"SessionCommandDispatcher", sessionCommandDispatcher,  ...
"CloseListeners", event.listener.empty,  ...
"DesignSuiteMap", designSuiteMap,  ...
"IsSimulationJobActive", false );
end 

function addListenerForModelCloseForSavingSession( modelHandle, sessionDataModel )
modelName = get_param( modelHandle, "Name" );
Simulink.addBlockDiagramCallback( modelName, "CloseRequest",  ...
"CloseModelAndSession", @(  )simulink.multisim.internal.confirmSaveOnModelCloseRequest( modelHandle, sessionDataModel ) );
end 

function addListenerForModelNameChangeForUpdatingDesignStudies( modelHandle )
modelName = get_param( modelHandle, "Name" );
Simulink.addBlockDiagramCallback( modelHandle, "PostNameChange", "UpdateDesignStudies",  ...
@(  )simulink.multisim.internal.updateDesignStudiesOnSaveAs( modelHandle, modelName ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpoIPfTQ.p.
% Please follow local copyright laws when handling this file.

