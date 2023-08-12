













































classdef Workspace < handle
properties ( Access = private )
App
SimulationHelper
end 

properties ( SetAccess = private )
InitialStateSets
ExternalInputSets
ModelParameterSets
ReferenceWorkspaceVariableSets
end 

methods ( Access = { ?simulink.compiler.app.SimulationHelper, ?matlab.mock.classes.WorkspaceMock } )
function obj = Workspace( simulationHelper )










R36
simulationHelper( 1, 1 )simulink.compiler.app.SimulationHelper
end 

obj.App = simulationHelper.App;
obj.SimulationHelper = simulationHelper;
end 
end 

methods 
function updateReferencedVariable( obj, variable, setName )








[ varNameTop, ~ ] = obj.variableNameParts( variable.Name );

set = obj.ReferenceWorkspaceVariableSets.( setName );

[ refWkspVar, index ] = obj.variableFromVariableSet( varNameTop, set );

if isempty( index )
return 
end 

if isequal( variable.Name, varNameTop )
assert( isequal( refWkspVar.Name, varNameTop ) );
refWkspVar = obj.typePreservingVarUpdate( refWkspVar, variable.Value );
else 
assert( isstruct( refWkspVar.Value ) );
refWkspVar = obj.typePreservingStructVarUpdate( refWkspVar, variable.Name, variable.Value );
end 

set( index ) = refWkspVar;

obj.updateCachedWorkspaceVarSet( setName, set );
end 

function [ names, values ] = flattenVariables( obj, setName )








import simulink.compiler.internal.util.flattenStructData;

names = {  };
values = {  };

if ~isfield( obj.ReferenceWorkspaceVariableSets, setName )
msgKey = 'simulinkcompiler:genapp:SetNotFoundInRefVarSets';
notFoundMsg = message( msgKey, setName ).getString;
obj.SimulationHelper.UserInterface.setStatusMessage( notFoundMsg );
return 
end 

variablesSet = obj.ReferenceWorkspaceVariableSets.( setName );

assert( ~isempty( variablesSet ) );

for pIdx = 1:length( variablesSet )
[ names, values ] = flattenStructData(  ...
names,  ...
values,  ...
variablesSet( pIdx ).Name,  ...
variablesSet( pIdx ).Value );
end 
numRows = length( names );

assert( length( values ) == numRows );
end 

function update( obj, vars )












if isfield( vars, 'externalInputs' ) && ~isempty( vars.externalInputs )
obj.ExternalInputSets = vars.externalInputs;
end 

if isfield( vars, 'wkspVariables' ) && ~isempty( vars.wkspVariables )
obj.ReferenceWorkspaceVariableSets = vars.wkspVariables;
end 

if isfield( vars, 'modelParameters' ) && ~isempty( vars.modelParameters )
obj.ModelParameterSets = vars.modelParameters;
end 

if isfield( vars, 'initialStates' ) && ~isempty( vars.initialStates )
obj.InitialStateSets = vars.initialStates;
end 
end 

function extInpDSNames = externalInputsDataSetNames( obj )






extInpDSNames = obj.dataSetNames( obj.ExternalInputSets );
end 

function extInpDSNames = referenceWorkspaceVariablesDataSetNames( obj )






extInpDSNames = obj.dataSetNames( obj.ReferenceWorkspaceVariableSets );
end 

function extInpDSNames = initialStatesDataSetNames( obj )






extInpDSNames = obj.dataSetNames( obj.InitialStateSets );
end 
end 

methods ( Access = private )
function dataSetNames = dataSetNames( ~, sets )
dataSetNames = [  ];

if isempty( sets )
return 
end 
dataSetNames = fieldnames( sets );
end 

function [ varNameTop, varNameParts ] = variableNameParts( ~, variableName )
import simulink.compiler.internal.util.variableNameParts;
[ varNameTop, varNameParts ] = variableNameParts( variableName );
end 

function [ variable, index ] = variableFromVariableSet( ~, variableName, variableSet )
import simulink.compiler.internal.util.variableFromVariableSet;
[ variable, index ] = variableFromVariableSet( variableName, variableSet );
end 

function variable = typePreservingVarUpdate( ~, variable, newData )
import simulink.compiler.internal.util.typePreservingVarUpdate;
variable = typePreservingVarUpdate( variable, newData );
end 

function variable = typePreservingStructVarUpdate( ~, variable, fullVariableName, newData )
import simulink.compiler.internal.util.typePreservingStructVarUpdate;
variable = typePreservingStructVarUpdate( variable, fullVariableName, newData );
end 

function updateCachedWorkspaceVarSet( obj, setName, newValues )
obj.ReferenceWorkspaceVariableSets.( setName ) = newValues;
end 
end 

end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpHnGSup.p.
% Please follow local copyright laws when handling this file.

