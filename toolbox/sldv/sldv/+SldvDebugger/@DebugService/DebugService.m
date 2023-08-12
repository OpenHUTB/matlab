





classdef DebugService < SlicerApplication.DebugService

properties ( Access = public )
designMdl = [  ];
replacementModel = [  ];
DebugCtx SldvDebugger.DebugContext;
isExtractionWorkflow = false;
isReplacementWorkflow = false;
isSldvAnalysisHighlightActive = false;
sldvData = [  ];
end 

properties ( Access = protected )
sidObjIdMap = [  ];
end 


methods ( Access = public )
function obj = DebugService( model, sldvData )
isExtractionWorkflowInstance = false;
if isfield( sldvData.ModelInformation, 'ExtractedModel' ) ...
 && ~isempty( sldvData.ModelInformation.ExtractedModel )
isExtractionWorkflowInstance = true;
[ ~, ExtractedModelname, ~ ] = fileparts( sldvData.ModelInformation.ExtractedModel );
debugMdl = ExtractedModelname;
else 
debugMdl = model;
end 
obj@SlicerApplication.DebugService( debugMdl );
obj.isExtractionWorkflow = isExtractionWorkflowInstance;
obj.designMdl = model;
obj.sldvData = sldvData;
obj.criteriaTag = 'SldvGenerated';
obj.criteriaColor = 'Red';
if isfield( sldvData.ModelInformation, 'ReplacementModel' ) ...
 && ~isempty( sldvData.ModelInformation.ReplacementModel )
obj.isReplacementWorkflow = true;
[ ~, replacementModelName, ~ ] = fileparts( sldvData.ModelInformation.ReplacementModel );
obj.replacementModel = replacementModelName;
end 
obj.DebugCtx = SldvDebugger.DebugContext( obj.model );
obj.sidObjIdMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
obj.createSidObjIdMapping;
end 


setupSlicer( obj, SID, objectiveIdx );


bringUpInformer( obj, SID );

revertModelToOriginalState( obj );

setupSlicerCriteria( obj, currentObjectiveDescr );

sliceCriteria = setupExtraSlicerCriteriaForInspection( obj );

function result = isDebugEnabled( obj, SID )

ObjectIdx = obj.getObjectiveIdFromSid( SID );
result = ~isempty( ObjectIdx );
end 

function objId = getObjectiveIdFromSid( obj, SID )



objId = [  ];
if isKey( obj.sidObjIdMap, SID )
objId = obj.sidObjIdMap( SID );
end 
end 

function SID = getSidFromObjectiveIdx( obj, objectiveIdx )


modelObjectIdx = obj.sldvData.Objectives( objectiveIdx ).modelObjectIdx;
modelObjects = obj.sldvData.ModelObjects( modelObjectIdx );
if length( modelObjectIdx ) > 1


SID = filterParents( modelObjects );
else 
SID = string( modelObjects.designSid );
end 

function SIDs = filterParents( modelObjects )





SIDs = string( { modelObjects.designSid } );
parentBlocks = {  };
for idx = 1:length( SIDs )
if strcmpi( modelObjects( idx ).typeDesc, 'Model' )




parentBlocks = [ parentBlocks, SIDs( idx ) ];%#ok<AGROW> 
else 


parent = get_param( SIDs( idx ), 'Parent' );
parentBlocks = [ parentBlocks, Simulink.ID.getSID( parent ) ];%#ok<AGROW> 
end 
end 

parentBlocks = unique( parentBlocks );


SIDs = setdiff( SIDs, parentBlocks )';
end 
end 

function delete( obj )
obj.designMdl = [  ];
obj.sldvData = [  ];
obj.sidObjIdMap = [  ];
delete( obj.DebugCtx );
delete@SlicerApplication.DebugService( obj );
end 

function type = getObjectiveType( obj, objectiveIdx )

type = obj.sldvData.Objectives( objectiveIdx ).type;
end 

function setupSlicerConfiguration( obj, dlgSrc, objectiveId )

R36
obj( 1, 1 )
dlgSrc( 1, 1 )
objectiveId( 1, 1 )double
end 

startingPointH = obj.getSlicerSeed;



currentObjectiveDescr = obj.getObjectiveDescription( objectiveId );
obj.setupSlicerCriteria( currentObjectiveDescr );


sigList = dlgSrc.sigListPanel;
sigList.Model.addStart( startingPointH );
end 

function simInputValues = getSimulationInputValues( obj, objectiveId )
simInputValues = [  ];
if isfield( obj.sldvData.Objectives( objectiveId ), 'testCaseIdx' )
testCaseIdx = obj.sldvData.Objectives( objectiveId ).testCaseIdx;
simInputValues = obj.getSimInputValues( testCaseIdx );
end 
end 
end 

methods ( Access = protected )

startingPointH = getSlicerSeed( obj );
t = getTimeOfObservation( obj );
dlgSrc = setupSlicerDialog( obj );
simAndPause( obj, violationTime );
simulateForCoverage( obj, violationTime );
displayBannerMessage( obj );
yesno = getSldvModelHighlightStatus( obj );

function descr = getObjectiveDescription( obj, objectiveId )
descr = obj.sldvData.Objectives( objectiveId ).descr;
end 

function sid = updateSIDForExtractionReplacementWorkflow( obj, sid )

isBDExtractedModel = Sldv.DataUtils.isBDExtractedModel( obj.sldvData );
if obj.isExtractionWorkflow && ~isBDExtractedModel

for idx = 1:length( sid )
name = getfullname( sid( idx ) );
name = regexprep( name, [ '^', obj.designMdl ], obj.model );
sid( idx ) = string( Simulink.ID.getSID( name ) );
end 
end 
end 
end 

methods ( Abstract )
testCase = getTestCase( obj, idx );
simInputValues = getSimInputValues( obj, idx );
mapKey = getCriteriaMapKey( obj, objectiveId );
status = isObjectiveDebuggable( obj, objectiveId );
simButtonEnableMessage = getSimButtonEnableMessage( obj );
messageTag = getProgressIndicatorToLoadTestCase( obj );
messageTag = getProgressIndicatorStepToTime( obj );
messageTag = getCriteriaDescription( obj );
end 

methods ( Static )
function status = isGeneratedWithEnhancedMCDC( sldvData )


import SldvDebugger.sldvModeEnum
status = SldvDebugger.DebugService.getSldvMode( sldvData ) == sldvModeEnum.TestGenerationEnhancedMCDC;
end 

function status = isGeneratedForGenericTestGeneration( sldvData )


import SldvDebugger.sldvModeEnum
status = SldvDebugger.DebugService.getSldvMode( sldvData ) == sldvModeEnum.TestGenerationGeneric;
end 

function status = isGeneratedForTestGeneration( sldvData )


import SldvDebugger.sldvModeEnum SldvDebugger.DebugService.*;
status = isGeneratedForGenericTestGeneration( sldvData ) || isGeneratedWithEnhancedMCDC( sldvData );
end 

function status = getSldvMode( sldvData )


import SldvDebugger.sldvModeEnum
opts = sldvData.AnalysisInformation.Options;

status = sldvModeEnum.TestGenerationGeneric;
if strcmp( opts.Mode, 'DesignErrorDetection' )
status = sldvModeEnum.DesignErrorDetection;
elseif strcmp( opts.Mode, 'TestGeneration' ) && strcmp( opts.ModelCoverageObjectives, 'EnhancedMCDC' )
status = sldvModeEnum.TestGenerationEnhancedMCDC;
elseif strcmp( opts.Mode, 'PropertyProving' )
status = sldvModeEnum.PropertyProving;
end 
end 

function handles = getBlockHandleFromSID( SID )

R36
SID( :, : )string
end 
blockNames = getfullname( convertStringsToChars( SID ) );
handles = getSimulinkBlockHandle( blockNames );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQ4IYXp.p.
% Please follow local copyright laws when handling this file.

