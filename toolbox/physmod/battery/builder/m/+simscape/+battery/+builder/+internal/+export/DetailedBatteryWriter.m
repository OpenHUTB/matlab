classdef ( Sealed = true, Hidden = true )DetailedBatteryWriter < simscape.battery.builder.internal.export.SSCWriter




properties ( Dependent, Access = protected )
CoolingPathResistanceParameters
AmbientPathResistanceParameters
ParallelAssemblyVariables
end 

properties ( Constant, Access = protected )
ModelResolution = getString( message( "physmod:battery:builder:blocks:ModelResolutionDetailed" ),  ...
matlab.internal.i18n.locale( 'en_US' ) );
end 

properties ( Dependent, Access = private )
ChildScalingParameter
end 

methods 
function obj = DetailedBatteryWriter( batteryType )

R36
batteryType string{ mustBeMember( batteryType, [ "Module", "ParallelAssembly" ] ) }
end 
obj.BatteryType = batteryType;
end 

function resistanceParameters = get.CoolingPathResistanceParameters( obj )

childComponentParams = simscape.battery.builder.internal.export.ComponentParameters;
if obj.CoolantThermalPath ~= "" && obj.BatteryType == simscape.battery.builder.ParallelAssembly.Type
id = "CoolantResistance";
label = string( getString( message( 'physmod:battery:builder:blocks:CoolantResistance' ), matlab.internal.i18n.locale( 'en_US' ) ) );
defaultValue = "1.2";
defaultUnit = "K/W";
group = "Thermal";
childComponentParams = childComponentParams.addParameters( id, label, defaultValue, defaultUnit, group, "P" );
else 

end 

resistanceParameters = childComponentParams.getDefaultCompositeComponentParameters(  );
end 

function resistanceParameters = get.AmbientPathResistanceParameters( obj )

childComponentParams = simscape.battery.builder.internal.export.ComponentParameters;
if obj.AmbientThermalPath ~= "" && obj.BatteryType == simscape.battery.builder.ParallelAssembly.Type
id = "AmbientResistance";
label = string( getString( message( 'physmod:battery:builder:blocks:AmbientThermalPathResistance' ), matlab.internal.i18n.locale( 'en_US' ) ) );
defaultValue = "25";
defaultUnit = "K/W";
group = "Thermal";
childComponentParams = childComponentParams.addParameters( id, label, defaultValue, defaultUnit, group, "P" );
else 

end 

resistanceParameters = childComponentParams.getDefaultCompositeComponentParameters(  );
end 

function childScalingParameter = get.ChildScalingParameter( obj )

switch obj.BatteryType
case simscape.battery.builder.Module.Type
childScalingParameter = "P";
otherwise 

childScalingParameter = string.empty( 0, 1 );
end 
end 


function variables = get.ParallelAssemblyVariables( obj )

variables = simscape.battery.builder.internal.export.ComponentVariables(  );
switch obj.BatteryType
case simscape.battery.builder.ParallelAssembly.Type
voltageDescription = getString( message( 'physmod:battery:builder:blocks:ParallelAssemblyVoltage' ), matlab.internal.i18n.locale( 'en_US' ) );
variables = variables.addVariables( "vParallelAssembly", voltageDescription, "0", "1", "V", "priority.none" );
socDescription = getString( message( 'physmod:battery:builder:blocks:ParallelAssemblySOC' ), matlab.internal.i18n.locale( 'en_US' ) );
variables = variables.addVariables( "socParallelAssembly", socDescription, "1", "1", "1", "priority.none" );
otherwise 

end 
end 
end 

methods ( Hidden )
function component = addChildComponent( obj, component )



childScalingFactorMapping = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
[ "P", "S" ] );
childScalingFactor = childScalingFactorMapping( obj.BatteryType );
componentsSection = simscape.battery.internal.sscinterface.ComponentsSection( CompileReuse = "true" );
batteryIndex = childScalingFactor + "idx";

variableCount = length( obj.BatteryCompositeComponentVariables.IDs );
variablePriority = [ obj.BatteryCompositeComponentVariables.IDs, repmat( "priority.none", variableCount, 1 ) ];


compositeComponentParameters = obj.BatteryCompositeComponentParameters.IDs;
compositeComponentValues = obj.BatteryCompositeComponentParameters.Values;
scaledParametersIdx = obj.BatteryCompositeComponentParameters.Scaling == "P";
compositeComponentValues( scaledParametersIdx ) = compositeComponentValues( scaledParametersIdx ).append( "(((" + batteryIndex + "-1)*P+1):(" + batteryIndex + "*P))" );


compositeComponentParameters = [ obj.ChildScalingParameter, obj.ChildScalingParameter; ...
compositeComponentParameters, compositeComponentValues;obj.ControlParameters ];

compositeComponent = simscape.battery.internal.sscinterface.CompositeComponent( obj.ChildComponentIdentifier + "(" + batteryIndex + ")", obj.ChildComponent,  ...
Parameters = compositeComponentParameters, VariablePriority = variablePriority );

componentsSection = componentsSection.addComponent( compositeComponent );
forLoop = simscape.battery.internal.sscinterface.ForLoop( batteryIndex, "1:" + childScalingFactor );
forLoop = forLoop.addSection( componentsSection );
component = component.addForLoop( forLoop );
end 

function component = addCompositeComponentVariables( obj, component )


if ~isempty( obj.ComponentVariables.IDs )
scalingParameterMapping = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
[ "P", "S" ] );
scalingParameter = scalingParameterMapping( obj.BatteryType );
variables = obj.BatteryCompositeComponentVariables;
[ uniqueVariableSize, ~, variableSizeMapping ] = unique( variables.DefaultValuesSize );

loopingParameter = scalingParameter.append( "idx" );
forLoop = simscape.battery.internal.sscinterface.ForLoop( loopingParameter, "1:" + scalingParameter );
for currentVariableSizeIdx = 1:length( uniqueVariableSize )
switch uniqueVariableSize( currentVariableSizeIdx )
case { "S", "P" }
variableIndexingParameter = loopingParameter;
reshapeCommand = "";
reshapeSize = "";
otherwise 
variableIndexingParameter = "(Sidx*P-(P-1)):(Sidx*P)";
reshapeCommand = "reshape(";
reshapeSize = ",P,1)";
end 
equationsSection = simscape.battery.internal.sscinterface.EquationsSection(  );
for variableIdx = find( currentVariableSizeIdx == variableSizeMapping )'
childComponentVariable = obj.ChildComponentIdentifier.append( "(" + loopingParameter + ").", variables.IDs( variableIdx ) );
componentVariable = reshapeCommand + variables.Values( variableIdx ).append( "(", variableIndexingParameter, ")", reshapeSize );
equationsSection = equationsSection.addEquation( childComponentVariable,  ...
componentVariable );
end 
forLoop = forLoop.addSection( equationsSection );
end 
component = component.addForLoop( forLoop );
else 

end 
end 

function component = addNonCellResistor( obj, component )

if ~isempty( obj.NonCellResistanceParameters.IDs )
componentsSection = simscape.battery.internal.sscinterface.ComponentsSection(  );
nonCellResistor = simscape.battery.internal.sscinterface.CompositeComponent( obj.NonCellResistanceIdentifier, "foundation.electrical.elements.resistor", Parameters = [ "R", obj.NonCellResistanceParameters.IDs ] );
componentsSection = componentsSection.addComponent( nonCellResistor );
component = component.addSection( componentsSection );
else 

end 
end 

function component = addConnection( obj, component )


if ~isempty( obj.NonCellResistanceParameters.IDs )

connectionsSection = simscape.battery.internal.sscinterface.ConnectionsSection;
connectionsSection = connectionsSection.addConnection( "p", obj.NonCellResistanceIdentifier.append( ".p" ) );
component = component.addSection( connectionsSection );
nodeForBatteries = obj.NonCellResistanceIdentifier.append( ".n" );
else 

nodeForBatteries = "p";
end 

switch obj.BatteryType
case simscape.battery.builder.ParallelAssembly.Type

forLoop = simscape.battery.internal.sscinterface.ForLoop( "Pidx", "1:" + "P" );
connectionsSection = simscape.battery.internal.sscinterface.ConnectionsSection;
connectionsSection = connectionsSection.addConnection( nodeForBatteries, obj.ChildComponentIdentifier.append( "(Pidx).p" ) );
connectionsSection = connectionsSection.addConnection( obj.ChildComponentIdentifier.append( "(Pidx).n" ), "n" );
forLoop = forLoop.addSection( connectionsSection );
component = component.addForLoop( forLoop );
otherwise 

edgeConnectionsSection = simscape.battery.internal.sscinterface.ConnectionsSection;
edgeConnectionsSection = edgeConnectionsSection.addConnection( nodeForBatteries, obj.ChildComponentIdentifier.append( "(1).p" ) );
edgeConnectionsSection = edgeConnectionsSection.addConnection( "n", obj.ChildComponentIdentifier.append( "(end).n" ) );
forLoop = simscape.battery.internal.sscinterface.ForLoop( "Sidx", "1:" + "S-1" );
interiourConectionsSection = simscape.battery.internal.sscinterface.ConnectionsSection;
interiourConectionsSection = interiourConectionsSection.addConnection( obj.ChildComponentIdentifier + "(Sidx).n", obj.ChildComponentIdentifier + "(Sidx+1).p" );
forLoop = forLoop.addSection( interiourConectionsSection );
component = component.addSection( edgeConnectionsSection );
component = component.addForLoop( forLoop );
end 
end 

function component = addCoolingPlateConnections( obj, component )

import simscape.battery.internal.sscinterface.*
coolingPlateId = obj.CoolingPlateLocation;
coolingPlatePort = repmat( "", size( coolingPlateId ) );

if obj.CoolantThermalPath == "CellBasedThermalResistance" &&  ...
obj.BatteryType == simscape.battery.builder.ParallelAssembly.Type

componentsSection = ComponentsSection;
connectionsSection = ConnectionsSection;
for coolingPlateIdx = 1:length( coolingPlateId )

memberComponentName = "CoolantResistor" + coolingPlateId( coolingPlateIdx ) + "(Pidx)";
resistanceValue = obj.CoolingPathResistanceParameters.Values;
memberParameters = [ "resistance", resistanceValue.append( "(Pidx)" ) ];
compositeComponent = CompositeComponent( memberComponentName, "foundation.thermal.elements.resistance", "Parameters", memberParameters );
componentsSection = componentsSection.addComponent( compositeComponent );


connectionsSection = connectionsSection.addConnection( obj.ChildComponentIdentifier.append( "(Pidx).H" ), memberComponentName.append( ".A" ) );

coolingPlatePort( coolingPlateIdx ) = memberComponentName.append( ".B" );
end 
connectionsLoopingIndex = "Pidx";
connectionsForLoop = ForLoop( connectionsLoopingIndex, "1:P" );
connectionsForLoop = connectionsForLoop.addSection( componentsSection );
connectionsForLoop = connectionsForLoop.addSection( connectionsSection );

nodesLoopingIndex = "Pidx";
nodesForLoop = ForLoop( nodesLoopingIndex, "1:P" );

coolantVectorIndex = "Pidx";
elseif obj.BatteryType == simscape.battery.builder.ParallelAssembly.Type

connectionsLoopingIndex = "Pidx";
connectionsForLoop = ForLoop( connectionsLoopingIndex, "1:P" );
nodesLoopingIndex = "Pidx";
nodesForLoop = ForLoop( nodesLoopingIndex, "1:P" );
coolingPlatePort( : ) = obj.ChildComponentIdentifier.append( "(Pidx).H" );
coolantVectorIndex = "Pidx";
else 

connectionsLoopingIndex = "Sidx";
connectionsForLoop = ForLoop( connectionsLoopingIndex, "1:S" );
nodesLoopingIndex = "CellIdx";
nodesForLoop = ForLoop( nodesLoopingIndex, "1:S*P" );
coolingPlatePort( : ) = obj.ChildComponentIdentifier.append( "(Sidx).", coolingPlateId, "ExtClnt" );
coolantVectorIndex = "((Sidx-1)*P+1):(Sidx*P)";
end 

nodesSection = NodesSection(  );
annotationsSection = AnnotationsSection;
connectionsSection = ConnectionsSection;
for coolingPlateIdx = 1:length( coolingPlateId )

nodeName = coolingPlateId( coolingPlateIdx ).append( "ExtClnt" );
nodeLabel = "CP" + coolingPlateId( coolingPlateIdx ).extract( 1 );
nodesSection = nodesSection.addNode( nodeName + "(" + nodesLoopingIndex + ")", "foundation.thermal.thermal", Label = nodeLabel );
annotationsSection = annotationsSection.addPortLocation( nodeName, lower( coolingPlateId( coolingPlateIdx ) ) );


connectionsSection = connectionsSection.addConnection( coolingPlatePort( coolingPlateIdx ),  ...
nodeName.append( "(", coolantVectorIndex, ")" ) );
end 

nodesForLoop = nodesForLoop.addSection( nodesSection );
connectionsForLoop = connectionsForLoop.addSection( connectionsSection );
component = component.addForLoop( nodesForLoop );
component = component.addForLoop( connectionsForLoop );
component = component.addSection( annotationsSection );
end 

function component = addLumpedThermalPort( obj, component, portName, portLabel, resistanceName, resistanceParameter )

import simscape.battery.internal.sscinterface.*


nodesSection = NodesSection(  );
nodesSection = nodesSection.addNode( portName, "foundation.thermal.thermal", Label = portLabel );
component = component.addSection( nodesSection );

switch obj.BatteryType
case simscape.battery.builder.ParallelAssembly.Type

parallelForLoop = ForLoop( "Pidx", "1:P" );
componentsSection = ComponentsSection;
indexedResistanceName = resistanceName.append( "(Pidx)" );
memberParameters = [ "resistance", resistanceParameter.append( "(Pidx)" ) ];
compositeComponent = CompositeComponent( indexedResistanceName, "foundation.thermal.elements.resistance", Parameters = memberParameters );
componentsSection = componentsSection.addComponent( compositeComponent );
parallelForLoop = parallelForLoop.addSection( componentsSection );


connectionsSection = ConnectionsSection;
connectionsSection = connectionsSection.addConnection( obj.ChildComponentIdentifier.append( "(Pidx).H" ), indexedResistanceName.append( ".A" ) );
connectionsSection = connectionsSection.addConnection( indexedResistanceName.append( ".B" ), portName );
parallelForLoop = parallelForLoop.addSection( connectionsSection );
component = component.addForLoop( parallelForLoop );
otherwise 
seriesForLoop = ForLoop( "Sidx", "1:S" );
connectionsSection = ConnectionsSection;
connectionsSection = connectionsSection.addConnection( obj.ChildComponentIdentifier.append( "(Sidx)", ".", portName ), portName );
seriesForLoop = seriesForLoop.addSection( connectionsSection );
component = component.addForLoop( seriesForLoop );
end 
end 

function component = addParallelAssemblyVariables( obj, component )

switch obj.BatteryType
case simscape.battery.builder.ParallelAssembly.Type
equationsSection = simscape.battery.internal.sscinterface.EquationsSection;
equationsSection = equationsSection.addEquation( "vParallelAssembly", "vCellModel(1)" );
equationsSection = equationsSection.addEquation( "socParallelAssembly", "sum(socCellModel)/P" );
component = component.addSection( equationsSection );
otherwise 

end 
end 

function component = addScalingParameters( obj, component )




component = addScalingParameters@simscape.battery.builder.internal.export.SSCWriter( obj, component );


switch obj.BatteryType
case simscape.battery.builder.Module.Type
parametersSection = simscape.battery.internal.sscinterface.ParametersSection( ExternalAccess = "none" );
cellCountValue = obj.ScalingParameters.IDs.join( "*" );
parametersSection = parametersSection.addParameter( "CellCount",  ...
cellCountValue,  ...
getString( message( 'physmod:battery:builder:blocks:CellCount' ), matlab.internal.i18n.locale( 'en_US' ) ) );

component = component.addSection( parametersSection );
otherwise 


end 
end 

function component = addCellBalancing( obj, component )

switch obj.CellBalancing
case "Passive"
resistanceFactor = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
[ "", "*S" ] );
balancingComponents = obj.getCellBalancingComponents( "", resistanceFactor( obj.BatteryType ) );

enableIndex = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
[ "", "(1)" ] );
balancingConnections = obj.getCellBalancingConnections( enableIndex( obj.BatteryType ) );
component = component.addSection( balancingComponents );
component = component.addSection( balancingConnections );
otherwise 
end 
end 

function component = addScaledParameters( obj, component )

compositeComponenParameters = obj.ComponentParameters.getDefaultCompositeComponentParameters;
isScaledParameter = find( compositeComponenParameters.Scaling == "P" );
if ~isempty( isScaledParameter )
scaledParametersSection = simscape.battery.internal.sscinterface.ParametersSection( Access = "private" );
parameterSize = join( obj.ScalingParameters.IDs, "*" );
for scaledParameterIdx = isScaledParameter'
defaultDescription = compositeComponenParameters.Labels( scaledParameterIdx );
scaledDescription = "Scaled " + lower( defaultDescription.extractBefore( 2 ) ) + defaultDescription.extractAfter( 1 );
scaledParametersSection = scaledParametersSection.addParameter( compositeComponenParameters.Values( scaledParameterIdx ),  ...
compositeComponenParameters.IDs( scaledParameterIdx ).append( " .* ones(1,", parameterSize, ")" ), scaledDescription );
end 
component = component.addSection( scaledParametersSection );
end 
end 

function component = addScaledParameterAssertions( obj, component )


isScaledParameter = obj.ComponentParameters.Scaling ~= "1";

if any( isScaledParameter )
scalingParameterIDs = obj.ComponentParameters.IDs( isScaledParameter );
scalingParameterLabels = obj.ComponentParameters.Labels( isScaledParameter );
equationsSection = simscape.battery.internal.sscinterface.EquationsSection;
for parameterIdx = 1:length( scalingParameterIDs )
scalingFactor = join( obj.ScalingParameters.IDs, "*" );
condition = "isequal(size(" + scalingParameterIDs( parameterIdx ) + "),[1,1]) || isequal(size(" + scalingParameterIDs( parameterIdx ) + "),[1," + scalingFactor + "])";
diagnostic = getString( message( 'physmod:battery:builder:blocks:ScaledParameterAssertion', scalingParameterLabels( parameterIdx ), "number of cells modeled by the block" ),  ...
matlab.internal.i18n.locale( 'en_US' ) );
equationsSection = equationsSection.addAssertion( condition, ErrorMessage = diagnostic );
end 
component = component.addSection( equationsSection );
else 

end 
end 
end 

methods ( Access = protected )
function numericalSizes = getVariableNumericalSize( obj )


sizeMapping = dictionary( [ "1", "P", "S", "CellCount" ],  ...
[ "1", string( obj.ChildrenInParallel ), string( obj.ChildrenInSeries ), string( obj.ChildrenInParallel * obj.ChildrenInSeries ) ] );
numericalSizes = sizeMapping( obj.ComponentVariables.DefaultValuesSize );
end 

function description = getResolutionDescription( ~ )



description = "";
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpG8m83L.p.
% Please follow local copyright laws when handling this file.

