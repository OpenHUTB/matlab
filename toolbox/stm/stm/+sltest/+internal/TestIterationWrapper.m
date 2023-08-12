classdef TestIterationWrapper < handle





properties ( Dependent )
Name( 1, : )char;
Description( 1, : )char;
Enabled( 1, 1 )logical;
end 

properties ( SetAccess = protected, GetAccess = public )
ModelParams = {  };
TestParams = {  };
Variables = {  };
end 

properties ( Access = private )
SignalBuilderSettings = {  };

IterationId( 1, 1 ) =  - 1;



NameNoDatabase( 1, : )char;
DescriptionNoDatabase( 1, : )char;
EnabledNoDatabase( 1, 1 )logical = true;
end 

properties ( Access = protected )
TestID( 1, 1 ) =  - 1;
Type;
end 

properties ( Hidden )
UUID;
RevisionUUID;
end 

methods 

function this = TestIterationWrapper( iterationId, testCaseId )
if ( nargin > 0 )
this.getIterationSettings( iterationId );
end 

if ( nargin > 1 && this.TestID < 0 )
this.setTestCaseId( testCaseId );
end 
end 



function setTestParam( this, paramType, paramValue, NV )
R36
this( 1, 1 )sltest.testmanager.TestIteration;
paramType( 1, 1 )string;
paramValue;
NV.SimulationIndex( 1, 1 ){ mustBeMember( NV.SimulationIndex, [ 1, 2 ] ) } = 1;
end 

paramTypes = [ "ParameterSet", "Baseline", "ExternalInput", "ConfigSet",  ...
"PreLoadFcn", "PostLoadFcn", "PreStartRealTimeApplicationFcn", "CleanupFcn",  ...
"Description", "SignalBuilderGroup", "SignalEditorScenario",  ...
"LoggedSignalSet", "Assessments", "TestSequenceScenario" ];

paramType = validatestring( paramType, paramTypes );
if paramType == "SignalEditorScenario"


paramType = "SignalBuilderGroup";
end 

if paramType == "Assessments" && ~isempty( paramValue )
paramValue = jsonencode( paramValue );
end 

idx = this.getTestParamIdxToUpdate( paramType, NV.SimulationIndex );
this.TestParams{ idx } = { paramType, paramValue, NV.SimulationIndex };
end 

function update( this )
if ( this.IterationId < 0 )
error( message( 'stm:ScriptsView:FailToUpdateNonRegisteredIteration' ) );
end 

newIterationId = stm.internal.createTestIteration( this.TestID, '',  ...
this.ModelParams,  ...
this.TestParams,  ...
this.SignalBuilderSettings,  ...
this.Variables,  ...
this.Description,  ...
this.IterationId );

if ( this.TestID > 0 )
stm.internal.updateTableIterationUI( this.TestID, newIterationId );
this.IterationId = newIterationId;
end 
end 

function tir = getIterationResults( this )
tirID = stm.internal.getIterationProperty( this.IterationId, 'TestIterationResult' );
tir = sltest.testmanager.TestIterationResult.empty;
tir = [ tir, arrayfun( @( id )sltest.testmanager.TestIterationResult( id ), tirID ) ];
end 

function set.Enabled( this, val )
this.setHelper( val, 'Enabled', 'EnabledNoDatabase' );
end 

function ret = get.Enabled( this )
ret = this.getHelper( 'Enabled', 'EnabledNoDatabase' );
end 

function set.Name( this, val )
R36
this;
val( 1, 1 )string{ mustBeNonzeroLengthText };
end 
val = sltest.testmanager.Test.replaceControlCharacters( val );
this.setHelper( val, 'Name', 'NameNoDatabase' );
end 

function ret = get.Name( this )
ret = this.getHelper( 'Name', 'NameNoDatabase' );
end 

function set.Description( this, val )
this.setHelper( val, 'TestDescription', 'DescriptionNoDatabase' );
end 

function ret = get.Description( this )
ret = this.getHelper( 'TestDescription', 'DescriptionNoDatabase' );
end 

function ret = get.UUID( this )
ret = this.getIterationProperties.uuid;
end 

function ret = get.RevisionUUID( this )
ret = this.getIterationProperties.RevisionUUID;
end 
end 

methods ( Hidden )
function id = getIterationId( this )
id = [ this.IterationId ];
end 

function id = getID( this )
id = this.getIterationId;
end 

function id = getTestID( this )
id = this.TestID;
end 

function out = getIterationProperties( this )
out = stm.internal.getTestIterationProperty( this.IterationId );
end 



function register( this, name, testCaseId )
R36
this;
name = '';
testCaseId = this.TestID;
end 


this.IterationId = stm.internal.createTestIteration( testCaseId, name,  ...
this.ModelParams,  ...
this.TestParams,  ...
this.SignalBuilderSettings,  ...
this.Variables,  ...
this.Description,  ...
 - 1 );
if ( this.IterationId <= 0 )
error( message( 'stm:ScriptsView:FailedToAddIterationToTestCase' ) );
end 
end 

function getIterationSettings( this, iterationId )
this.IterationId = iterationId;
iterationProperty = stm.internal.getTestIterationProperty( this.IterationId );
if ( ~isempty( iterationProperty.testCaseId ) )
this.TestID = iterationProperty.testCaseId;
end 

this.ModelParams = {  };
this.TestParams = {  };
this.SignalBuilderSettings = {  };
this.Variables = {  };
for k = 1:length( iterationProperty.ModelParameters )
sysHandle = iterationProperty.ModelParameters( k ).sysHandle;
param = iterationProperty.ModelParameters( k ).parameter;
value = iterationProperty.ModelParameters( k ).value;
indexOfSim = iterationProperty.ModelParameters( k ).simulationIndex;
[ ~, displayText ] = stm.internal.util.getDisplayValue( value );
this.ModelParams{ end  + 1 } = { sysHandle, param, value, indexOfSim, displayText };
end 
for k = 1:length( iterationProperty.SignalBuilderGroups )
sysHandle = iterationProperty.SignalBuilderGroups( k ).signalBuilderBlock;
param = 'ActiveGroup';
value = iterationProperty.SignalBuilderGroups( k ).groupName;
indexOfSim = iterationProperty.SignalBuilderGroups( k ).simulationIndex;
this.ModelParams{ end  + 1 } = { sysHandle, param, value, indexOfSim, '' };
end 

for k = 1:length( iterationProperty.TestParameters )
paramType = iterationProperty.TestParameters( k ).parameter;
if ( ~isempty( paramType ) )
paramValue = iterationProperty.TestParameters( k ).value;
indexOfSim = iterationProperty.TestParameters( k ).simulationIndex;
this.TestParams{ end  + 1 } = { paramType, paramValue, indexOfSim };
end 
end 

for k = 1:length( iterationProperty.Variables )
name = iterationProperty.Variables( k ).name;
value = iterationProperty.Variables( k ).value;
source = iterationProperty.Variables( k ).source;
indexOfSim = iterationProperty.Variables( k ).simulationIndex;
[ ~, displayText ] = stm.internal.util.getDisplayValue( value );
this.Variables{ end  + 1 } = { name, value, source, indexOfSim, displayText };
end 
end 

function setTestCaseId( this, testCaseId )
this.TestID = testCaseId;
end 
end 

methods ( Access = private )
function setHelper( this, val, mcosName, propName )
if this.getID > 0
stm.internal.setIterationProperty( this.getID, mcosName, val );
else 
this.( propName ) = val;
end 
end 

function ret = getHelper( this, mcosName, propName )
if this.getID > 0
ret = stm.internal.getIterationProperty( this.getID, mcosName );
else 
ret = this.( propName );
end 
end 

function idx = getTestParamIdxToUpdate( this, paramType, simIndex )


paramTypes = string( cellfun( @( param )string( param{ 1 } ), this.TestParams ) );
simIndexes = cellfun( @( param )param{ 3 }, this.TestParams );
typeIdx = paramTypes == paramType;
simIndex = simIndexes == simIndex;
stack = [ typeIdx;simIndex ];
dupIdx = all( stack );
assert( nnz( dupIdx ) <= 1 );

if any( dupIdx )

idx = dupIdx;
else 

idx = numel( this.TestParams ) + 1;
end 
end 
end 

methods ( Static )



function setSignalBuilderGroup( this, sysHandle, group, simIndex )
R36
this;
sysHandle( 1, : )char{ mustBeNonempty };
group( 1, : )char{ mustBeNonempty };
simIndex;
end 

this.SignalBuilderSettings{ end  + 1 } = { sysHandle, group, simIndex };
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpK92CdM.p.
% Please follow local copyright laws when handling this file.

