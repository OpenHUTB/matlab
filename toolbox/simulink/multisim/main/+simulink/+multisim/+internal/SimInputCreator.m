classdef SimInputCreator < handle




properties ( Access = private )
ModelName
DesignPoints simulink.multisim.internal.DesignPoint
BlockParamTypeList simulink.multisim.mm.design.ParameterType
BlockParamList Simulink.Simulation.BlockParameter

end 

methods 
function obj = SimInputCreator( modelName, designPoints )
R36
modelName( 1, 1 )string
designPoints( 1, : )simulink.multisim.internal.DesignPoint
end 

obj.ModelName = modelName;
obj.DesignPoints = designPoints;
end 

function simIns = createSimInputs( obj )
numSims = numel( obj.DesignPoints );
simInp = Simulink.SimulationInput( obj.ModelName );

simInp = SlCov.CoverageAPI.setupSimInputForRunall( simInp );
simIns( 1:numSims ) = simInp;

for designPointIdx = 1:numel( obj.DesignPoints )
set_param( obj.ModelName, "StatusString", getString( message(  ...
"multisim:SetupGUI:MultiSimSetUpProgress", designPointIdx, numSims ) ) );
paramSamples = obj.DesignPoints( designPointIdx ).ParameterSamples;
for paramSampleIdx = 1:numel( paramSamples )
paramSampleType = paramSamples( paramSampleIdx ).ParameterType;
switch paramSampleType.StaticMetaClass.name
case "BlockParameter"
simIns( designPointIdx ) = obj.addBlockParameterToSimInput( simIns( designPointIdx ),  ...
paramSamples( paramSampleIdx ) );

case "Variable"
simIns( designPointIdx ) = obj.addVariableToSimInput( simIns( designPointIdx ),  ...
paramSamples( paramSampleIdx ) );

case "FaultSet"
simIns( designPointIdx ) = obj.addFaultSetToSimInput( simIns( designPointIdx ),  ...
paramSamples( paramSampleIdx ) );
end 
end 
end 
end 
end 

methods ( Access = private )
function simIn = addBlockParameterToSimInput( obj, simIn, blockParamSample )
blockParamType = blockParamSample.ParameterType;
value = blockParamSample.Value;
if blockParamType.ConvertValueToString &&  ...
~matlab.internal.datatypes.isScalarText( value )
value = mat2str( value );
end 

index = find( obj.BlockParamTypeList == blockParamType );
if isempty( index )
blockPath = blockParamType.BlockPath;
blockParamName = blockParamType.Name;
blockParam = Simulink.Simulation.BlockParameter( blockPath, blockParamName, value );
obj.BlockParamList = [ obj.BlockParamList, blockParam ];
obj.BlockParamTypeList = [ obj.BlockParamTypeList, blockParamType ];
else 
blockParam = obj.BlockParamList( index );
blockParam.Value = value;
end 
simIn = simIn.setBlockParameter( blockParam );
end 

function simIn = addVariableToSimInput( obj, simIn, variableSample )
varName = variableSample.ParameterType.Name;
varWorkspace = variableSample.ParameterType.Workspace;
value = variableSample.Value;
simIn = simIn.setVariable( varName, value, "Workspace", varWorkspace );
end 

function simIn = addFaultSetToSimInput( obj, simIn, faultSetSample )





if ~simulink.multisim.internal.isFaultInjectionAvailable(  )
return 
end 

value = faultSetSample.Value;


oldValue = 'MultiSim;';
for it = simIn.ModelParameters
if strcmp( it.Name, 'SimFaults' )
oldValue = it.Value;
break 
end 
end 
value = strcat( oldValue, value, ';' );
simIn = simIn.setModelParameter( 'SimFaults', value );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpxQSoZz.p.
% Please follow local copyright laws when handling this file.

