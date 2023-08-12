















classdef TemporaryModelState < handle
properties 
RevertOnDelete = true
end 

properties ( Access = private )
AppliedSimulationInput
RevertedSimulationInput
ModelWSVarsToDelete = struct
ExternalDataAccessor
ExternalDataCruft
InitialRefSignals
RevertLogging = false
end 

methods 
function obj = TemporaryModelState( simIn, varargin )
validateattributes( simIn, { 'Simulink.SimulationInput' }, { 'scalar' } );
obj.AppliedSimulationInput = simIn;
obj.apply( varargin{ : } );
end 

function delete( obj )
if obj.RevertOnDelete
obj.revert(  );
end 
end 
end 

methods ( Hidden )
function simIn = getAppliedSimulationInput( obj )
simIn = obj.AppliedSimulationInput;
end 

function revert( obj )
if obj.RevertLogging
obj.clearModelLoggedSignals(  );
obj.restoreRefModelsLoggedSignals(  );
obj.RevertLogging = false;
end 

obj.RevertedSimulationInput.applyToModel( 'EnableConfigSetRefUpdate', 'on' );

revertExternalData( obj );
revertModelWS( obj );
end 

end 

methods ( Access = private )
function apply( obj, varargin )
obj.InitialRefSignals = containers.Map;

modelName = obj.AppliedSimulationInput.getModelNameForApply(  );

load_system( modelName );



obj.ExternalDataAccessor = Simulink.data.DataAccessor.createForExternalData( modelName );
externalVarIdsBeforeApply = obj.ExternalDataAccessor.identifyVisibleVariables(  );



modelRefs = find_mdlrefs( modelName,  ...
'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );

modelWSVarsBeforeApply = struct;
oc = [  ];
isModelLocked = @( mdl )strcmpi( get_param( mdl, 'Lock' ), 'on' );
for i = 1:numel( modelRefs )
if ~bdIsLoaded( modelRefs{ i } )
load_system( modelRefs{ i } );
oc = onCleanup( @(  )close_system( modelRefs{ i }, 0 ) );
end 
if ~isModelLocked( modelRefs{ i } )
modelWS = get_param( modelRefs{ i }, 'modelworkspace' );
modelWSVarsBeforeApply.( modelRefs{ i } ) = modelWS.evalin( 'who' );
modelInitialSignals = get_param( modelRefs{ i }, 'InstrumentedSignals' );
obj.InitialRefSignals( modelRefs{ i } ) = modelInitialSignals;
end 
end 
delete( oc );

obj.createRevertedSimulationInput( varargin{ : } );
obj.AppliedSimulationInput.applyToModel( varargin{ : } );
externalVarIdsAfterApply = obj.ExternalDataAccessor.identifyVisibleVariables(  );
obj.ExternalDataCruft = Simulink.data.VariableIdentifier.setdiffVarIds( externalVarIdsAfterApply,  ...
externalVarIdsBeforeApply );




for i = 1:numel( modelRefs )
bdWasLoaded = false;
if ~bdIsLoaded( modelRefs{ i } )
load_system( modelRefs{ i } );
bdWasLoaded = true;
end 
if ~isModelLocked( modelRefs{ i } )
modelWS = get_param( modelRefs{ i }, 'modelworkspace' );
obj.ModelWSVarsToDelete.( modelRefs{ i } ) = setdiff( modelWS.evalin( 'who' ), modelWSVarsBeforeApply.( modelRefs{ i } ) );
if isempty( obj.ModelWSVarsToDelete.( modelRefs{ i } ) ) && bdWasLoaded
close_system( modelRefs{ i }, 0 );
end 
end 
end 
end 

function createRevertedSimulationInput( obj, options )
R36
obj
options.EnableConfigSetRefUpdate( 1, 1 )matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off
options.ApplyHidden( 1, 1 )matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off
end 

simIn = obj.AppliedSimulationInput;

modelName = obj.AppliedSimulationInput.getModelNameForApply(  );
load_system( modelName );

obj.RevertedSimulationInput = simIn.constructDefaultObject;
obj.RevertedSimulationInput.CreatedForRevert = true;

if options.ApplyHidden && ~isempty( simIn.LoggingSpecification )
obj.RevertLogging = true;
end 

simIn = Simulink.Simulation.internal.processSimulationInputForRevert( simIn,  ...
"ProcessHidden", options.ApplyHidden );

if options.ApplyHidden
simIn = Simulink.Simulation.internal.getSimulationInputWithHiddenParamsVisible( simIn );
end 
simIn = Simulink.Simulation.internal.removeSimOnlyParams( simIn );

obj.parseInitialState( simIn );
obj.parseExternalInput( simIn );
obj.parseModelParameters( simIn );
obj.parseBlockParameters( simIn );
obj.parseVariables( simIn );

existedVarIds = obj.parseSimIn2VarIds( simIn );
obj.ExternalDataAccessor.captureVariableValues( existedVarIds );
end 

function clearModelLoggedSignals( obj )
modelName = obj.RevertedSimulationInput.getModelNameForApply(  );
set_param( modelName, 'InstrumentedSignals', [  ] );
end 

function restoreRefModelsLoggedSignals( obj )
modelName = obj.RevertedSimulationInput.getModelNameForApply(  );


modelRefs = find_mdlrefs( modelName, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );

isModelLocked = @( mdl )strcmpi( get_param( mdl, 'Lock' ), 'on' );

for i = 1:numel( modelRefs )
if bdIsLoaded( modelRefs{ i } ) && ~isModelLocked( modelRefs{ i } )
cachedSignals = obj.InitialRefSignals( modelRefs{ i } );
set_param( modelRefs{ i }, 'InstrumentedSignals', cachedSignals );
end 
end 
end 

function parseInitialState( obj, simIn )
if ~isempty( simIn.InitialState )
modelName = obj.AppliedSimulationInput.getModelNameForApply(  );
obj.RevertedSimulationInput = obj.RevertedSimulationInput.setModelParameter(  ...
'InitialState', get_param( modelName, 'InitialState' ),  ...
'LoadInitialState', get_param( modelName, 'LoadInitialState' ) );
end 
end 

function parseExternalInput( obj, simIn )
if ~isempty( simIn.ExternalInput )
modelName = obj.AppliedSimulationInput.getModelNameForApply(  );
obj.RevertedSimulationInput = obj.RevertedSimulationInput.setModelParameter(  ...
'ExternalInput', get_param( modelName, 'ExternalInput' ),  ...
'LoadExternalInput', get_param( modelName, 'LoadExternalInput' ) );
end 
end 

function parseModelParameters( obj, simIn )
modelParams = simIn.ModelParameters;
modelName = obj.AppliedSimulationInput.getModelNameForApply(  );
for i = 1:numel( modelParams )
modelParams( i ).Value = get_param( modelName, modelParams( i ).Name );
end 
obj.RevertedSimulationInput.ModelParameters = [ obj.RevertedSimulationInput.ModelParameters, modelParams ];
end 

function parseBlockParameters( obj, simIn )
blockParams = simIn.BlockParameters;
for i = 1:numel( blockParams )
blockParams( i ).Value = get_param( blockParams( i ).BlockPath, blockParams( i ).Name );
end 
obj.RevertedSimulationInput.BlockParameters = [ obj.RevertedSimulationInput.BlockParameters, blockParams ];
end 

function parseVariables( obj, simIn )
varsWksps = { simIn.Variables.Workspace };
simInVars = simIn.Variables( ~strcmp( varsWksps, "global-workspace" ) );
keepVars = true( 1, numel( simInVars ) );
modelName = obj.AppliedSimulationInput.getModelNameForApply(  );
for i = 1:numel( simInVars )
varName = simInVars( i ).Name;
keepVars( i ) = obj.variableExistsInWorkspace( modelName, varName, simInVars( i ).Workspace );
if keepVars( i )
simInVars( i ).Value = obj.getVariableValue( modelName, varName, simInVars( i ).Workspace );
end 
end 
obj.RevertedSimulationInput.Variables = [ obj.RevertedSimulationInput.Variables, simInVars( keepVars ) ];
end 

function existedExternalVarIds = parseSimIn2VarIds( obj, simIn )


existedExternalVarIds = [  ];
dataAccessor = obj.ExternalDataAccessor;
varsWksps = { simIn.Variables.Workspace };
simInVars = simIn.Variables( strcmp( varsWksps, "global-workspace" ) );
for i = 1:numel( simInVars )
varName = simInVars( i ).Name;
varIds = dataAccessor.identifyByName( varName );
if ~isempty( varIds )
existedExternalVarIds = [ existedExternalVarIds, varIds ];%#ok
end 
end 
end 

function revertExternalData( obj )
if ~isempty( obj.ExternalDataAccessor )
for i = 1:numel( obj.ExternalDataCruft )
obj.ExternalDataAccessor.deleteVariable( obj.ExternalDataCruft( i ) );
end 
obj.ExternalDataAccessor.restoreCapturedVariableValues(  );
end 
end 

function revertModelWS( obj )
modelNames = fieldnames( obj.ModelWSVarsToDelete );

for i = 1:numel( modelNames )
modelName = modelNames{ i };
if ~isempty( obj.ModelWSVarsToDelete.( modelName ) )
Simulink.Simulation.internal.loadModelForApply( modelName, true );
modelWS = get_param( modelName, 'modelworkspace' );
modelWS.evalin( [ 'clear ', strjoin( obj.ModelWSVarsToDelete.( modelName ), ' ' ) ] );
end 
end 
end 
end 

methods ( Static, Access = private )

function TF = variableExistsInWorkspace( modelName, varName, varWorkspace )
switch varWorkspace
case 'global-workspace'
TF = existsInGlobalScope( modelName, varName );

otherwise 

load_system( varWorkspace );
modelWS = get_param( varWorkspace, 'ModelWorkspace' );
TF = modelWS.hasVariable( varName );
end 
end 

function varValue = getVariableValue( modelName, varName, varWorkspace )
switch varWorkspace
case 'global-workspace'
varValue = evalinGlobalScope( modelName, varName );

otherwise 

load_system( varWorkspace );
modelWS = get_param( varWorkspace, 'ModelWorkspace' );
varValue = modelWS.evalin( varName );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmppj4geC.p.
% Please follow local copyright laws when handling this file.

