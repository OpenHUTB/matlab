classdef DebugService < handle





properties ( Access = public )
model = [  ];
isFastRestartSupported = true;
criteriaTag = '';
criteriaColor = 'Red';
criteriaMap = [  ];
end 

properties ( Access = protected )


modelRefs = [  ];
originalfastRestartValue = [  ];
originalDirtyFlagStatusMap = [  ];
isDebugSessionActive = false;
end 

events 
eventSetupComplete
end 

methods ( Access = public )
function obj = DebugService( mdl )

obj.model = mdl;
if ~exist( mdl )
return ;
end 


obj.modelRefs = find_mdlrefs( mdl, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );
obj.originalDirtyFlagStatusMap = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
obj.criteriaMap = containers.Map(  );
end 

function status = getIsDebugSessionActive( obj )
status = obj.isDebugSessionActive;
end 

function setIsDebugSessionActive( obj, status )
obj.isDebugSessionActive = status;
end 

function clearCriteriaMap( obj )
obj.criteriaMap.remove( keys( obj.criteriaMap ) );
end 


revertModelToOriginalState( obj );


dlg = createSlicerDialog( obj );

function backUpModelParameters( obj )


obj.originalfastRestartValue = get_param( obj.model, 'FastRestart' );


for i = 1:numel( obj.modelRefs )
if ~bdIsLoaded( obj.modelRefs{ i } )
load_system( obj.modelRefs{ i } );
end 
obj.originalDirtyFlagStatusMap( obj.modelRefs{ i } ) =  ...
get_param( obj.modelRefs{ i }, 'dirty' );
end 
end 

function clearGeneratedSlicerCriterion( obj )

if bdIsLoaded( obj.model )
slicerConfig = SlicerConfiguration.getConfiguration( obj.model );
slicerConfig.deleteCriterionByTag( obj.criteriaTag );
slicerConfig.saveConfigurationToFile;
end 
end 

function stopCurrentSim( obj )


if get_param( obj.model, 'ModelSlicerActive' )


if strcmp( get_param( obj.model, 'FastRestart' ), 'on' )
set_param( obj.model, 'SimulationCommand', 'stop' );
else 

slicerConfig = SlicerConfiguration.getConfiguration( obj.model );

slicerConfig.modelSlicer.terminateModelForTimeWindowSimulation(  );
end 
end 
end 

function switchToSimulationTab( obj )

modelHandle = get_param( obj.model, 'Handle' );
allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
studioHandles = arrayfun( @( s )s.App.blockDiagramHandle, allStudios );
studioIdx = find( studioHandles == modelHandle, 1 );
studio = allStudios( studioIdx );
toolStrip = studio.getToolStrip;
toolStrip.ActiveTab = 'globalSimulationTab';
end 

function delete( obj )
obj.model = [  ];
obj.isFastRestartSupported = true;
obj.criteriaTag = '';
obj.criteriaColor = '';
obj.criteriaMap = [  ];
obj.modelRefs = [  ];
obj.originalfastRestartValue = [  ];
obj.originalDirtyFlagStatusMap = [  ];
obj.isDebugSessionActive = false;
end 

function closeSlicer( obj )
msObj = modelslicerprivate( 'slicerMapper', 'get', obj.model );
editor = SlicerConfiguration.findEditor( obj.model );
studio = editor.getStudio;
msObj.dlg.delete;
studio.hideComponent( msObj.embedDDGComp );
end 

function disableCriteriaPanel( ~, dlg )
dlgSrc = dlg.getSource;
dlgSrc.criteriaListPanel.lockedForDebug = 1;
dlgSrc.sigListPanel.lockName = 1;
dlgSrc.criteriaListPanel.lockLoadSlms = 1;
dlg.refresh(  );
end 

function criteriaIndex = getCriteriaIndex( obj, criteriaTag )

criteriaIndex = [  ];
if isKey( obj.criteriaMap, criteriaTag )
existingSlicerCriteria = obj.criteriaMap( criteriaTag );
slicerConfig = SlicerConfiguration.getConfiguration( obj.model );
criteriaIndex = slicerConfig.getCriteriaIndexInSlicerConfiguration( existingSlicerCriteria );
if isempty( criteriaIndex )
remove( obj.criteriaMap, criteriaTag );
end 
end 
end 

function sliceCriteria = addSliceCriteriaForDebugWorkflows( obj, NameValueArgs )

R36
obj( 1, 1 )
NameValueArgs.criterionColor( 1, : )char = obj.criteriaColor
end 
slicerConfig = SlicerConfiguration.getConfiguration( obj.model );
sliceCriteria = slicerConfig.addCriterion( obj.criteriaTag );
sliceCriteria.setColor( NameValueArgs.criterionColor );
if ~isempty( sliceCriteria.overlay )
sliceCriteria.overlay.setStyleColor( sliceCriteria );
end 
sliceCriteria.refresh;
end 
end 

methods ( Static )
function highlightSid = updateSidForStateflowObjects( sid )

R36
sid( :, : )string
end 
highlightSid = sid;
for idx = 1:length( sid )
handle = Simulink.ID.getHandle( highlightSid( idx ) );
if ~isfloat( handle ) && handle.isa( 'Stateflow.Object' )
if isprop( handle, 'Chart' )
highlightSid( idx ) = string( Simulink.ID.getSID( handle.Chart ) );
elseif isprop( handle, 'Path' )


try 


highlightSid( idx ) = string( Simulink.ID.getSID( handle.Path ) );
catch 
error( 'Sldv:DebugUsingSlicer:InvalidBlockBeingObserved', getString( message( 'Sldv:DebugUsingSlicer:InvalidBlockBeingObserved' ) ) );
end 
else 
error( 'Sldv:DebugUsingSlicer:InvalidBlockBeingObserved', getString( message( 'Sldv:DebugUsingSlicer:InvalidBlockBeingObserved' ) ) );
end 
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4U9K8j.p.
% Please follow local copyright laws when handling this file.

