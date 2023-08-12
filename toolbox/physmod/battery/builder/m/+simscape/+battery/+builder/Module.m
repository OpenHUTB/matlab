classdef ( Sealed )Module < simscape.battery.builder.internal.Battery











































































































































properties ( Dependent )



NumSeriesAssemblies( 1, 1 )double{ mustBeInteger,  ...
mustBeInRange( NumSeriesAssemblies, 1, 150 ) }





ParallelAssembly( 1, 1 )simscape.battery.builder.ParallelAssembly









ModelResolution( :, 1 )string{ mustBeMember( ModelResolution,  ...
[ "Lumped", "Detailed", "Grouped" ] ) }










SeriesGrouping( 1, : )double ...
{ mustBeInteger, mustBePositive( SeriesGrouping ) }










ParallelGrouping( 1, : )double ...
{ mustBeInteger, mustBePositive( ParallelGrouping ) }



InterParallelAssemblyGap( 1, 1 ){ mustBeA( InterParallelAssemblyGap, [ "simscape.Value", "double" ] ) }


BalancingStrategy( 1, 1 )string{ mustBeMember( BalancingStrategy,  ...
[ "Passive", "" ] ) }



AmbientThermalPath( 1, 1 )string{ mustBeMember( AmbientThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) }






CoolantThermalPath( 1, 1 )string{ mustBeMember( CoolantThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) }



CoolingPlate( :, 1 )string{ mustBeMember( CoolingPlate,  ...
[ "Top", "Bottom", "" ] ) }



Position( 1, 3 )double{ mustBeReal, mustBeFinite }

Name( 1, 1 )string



StackingAxis( 1, 1 )string{ mustBeMember( StackingAxis,  ...
[ "X", "Y" ] ) }




MassFactor( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( MassFactor, 1 ) }



NonCellResistance( 1, 1 )string{ mustBeMember( NonCellResistance,  ...
[ "Yes", "No" ] ) }
end 

properties ( Dependent, SetAccess = private, GetAccess = public )


PackagingVolume( 1, 1 ){ mustBeA( PackagingVolume, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( PackagingVolume, "m^3" ) }


CumulativeMass( 1, 1 ){ mustBeA( CumulativeMass, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( CumulativeMass, "kg" ) }


NumModels( 1, 1 )double{ mustBeInteger }
end 

properties ( Access = private )



NumSeriesAssembliesInternal( 1, 1 )double{ mustBeInteger,  ...
mustBeInRange( NumSeriesAssembliesInternal, 1, 300 ) } = 1





ParallelAssemblyInternal simscape.battery.builder.ParallelAssembly




ModelResolutionInternal( :, 1 )string{ mustBeMember( ModelResolutionInternal,  ...
[ "Lumped", "Detailed", "Grouped" ] ) }



SeriesGroupingInternal( 1, : )double{ mustBeInteger, mustBePositive( SeriesGroupingInternal ) }



ParallelGroupingInternal( 1, : )double{ mustBeInteger, mustBePositive( ParallelGroupingInternal ) }



BalancingStrategyInternal( 1, 1 )string{ mustBeMember( BalancingStrategyInternal,  ...
[ "Passive", "" ] ) }



AmbientThermalPathInternal( 1, 1 )string{ mustBeMember( AmbientThermalPathInternal,  ...
[ "CellBasedThermalResistance", "" ] ) }






CoolantThermalPathInternal( 1, 1 )string{ mustBeMember( CoolantThermalPathInternal,  ...
[ "CellBasedThermalResistance", "" ] ) }



CoolingPlateInternal( :, 1 )string{ mustBeMember( CoolingPlateInternal,  ...
[ "Top", "Bottom", "" ] ) }



InterParallelAssemblyGapInternal( 1, 1 ){ mustBeA( InterParallelAssemblyGapInternal, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( InterParallelAssemblyGapInternal, "m" ) } = simscape.Value( 1 / 1000, "m" )

end 

properties ( Dependent, SetAccess = protected, Hidden )


SimulationToHardwareMapping( :, : )uint16{ mustBeInteger }
end 

properties ( SetAccess = private )


CellNumbering



ThermalNodes
end 


properties ( SetAccess = private, Hidden )


ParallelAssemblies( :, 1 )


Layout


ParallelAssemblyColors( :, 1 )

BatteryPatchDefinition( :, 1 )

RemainderCellPosition( :, 1 )string{ mustBeMember(  ...
RemainderCellPosition, [ "Odd", "Even" ] ) } = "Odd"


StackingAxisInternal( 1, 1 )string{ mustBeMember( StackingAxisInternal,  ...
[ "X", "Y" ] ) } = "Y"




MassFactorInternal( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( MassFactorInternal, 1 ) } = 1


ThermalBoundaryConditions



PositionInternal simscape.battery.builder.internal.Position

NameInternal( 1, 1 )string



NonCellResistanceInternal( 1, 1 )string{ mustBeMember( NonCellResistanceInternal,  ...
[ "Yes", "No" ] ) } = "No"
BlockTypeInternal
end 


properties ( Dependent, Hidden )
BlockType
end 

properties ( SetAccess = private, Dependent, Hidden )


Columns( 1, 1 )double{ mustBeInteger }


ParallelAssemblyRelativePositions

SimulationStrategyPatchDefinition( :, 1 )
end 

properties ( Constant )

Type = "Module"
end 

methods 
function obj = Module( namedArgs )
R36
namedArgs.NumSeriesAssemblies( 1, 1 )double{ mustBeInteger,  ...
mustBeInRange( namedArgs.NumSeriesAssemblies, 1, 150 ) } = 1
namedArgs.ParallelAssembly( 1, 1 )simscape.battery.builder.ParallelAssembly = simscape.battery.builder.ParallelAssembly(  )
namedArgs.ModelResolution( :, 1 )string{ mustBeMember( namedArgs.ModelResolution,  ...
[ "Lumped", "Detailed", "Grouped" ] ) } = "Lumped"
namedArgs.SeriesGrouping( 1, : )double ...
{ mustBeInteger, mustBePositive( namedArgs.SeriesGrouping ) } = [  ]
namedArgs.ParallelGrouping( 1, : )double ...
{ mustBeInteger, mustBePositive( namedArgs.ParallelGrouping ) } = [  ]
namedArgs.InterParallelAssemblyGap( 1, 1 ){ mustBeA( namedArgs.InterParallelAssemblyGap, [ "simscape.Value", "double" ] ) } = simscape.Value( 1 / 1000, "m" )
namedArgs.BalancingStrategy( 1, 1 )string{ mustBeMember( namedArgs.BalancingStrategy,  ...
[ "Passive", "" ] ) } = ""
namedArgs.AmbientThermalPath( 1, 1 )string{ mustBeMember( namedArgs.AmbientThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) } = ""
namedArgs.CoolantThermalPath( 1, 1 )string{ mustBeMember( namedArgs.CoolantThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) } = ""
namedArgs.CoolingPlate( :, 1 )string{ mustBeMember( namedArgs.CoolingPlate,  ...
[ "Top", "Bottom", "" ] ) } = ""
namedArgs.Position( 1, 3 )double{ mustBeReal, mustBeFinite } = [ 0, 0, 0 ]
namedArgs.StackingAxis( 1, 1 )string{ mustBeMember( namedArgs.StackingAxis,  ...
[ "X", "Y" ] ) } = "Y"
namedArgs.MassFactor( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( namedArgs.MassFactor, 1 ) } = 1
namedArgs.Name( 1, 1 )string = "Module1"
namedArgs.NonCellResistance( 1, 1 )string = "No"
end 

if ~pmsl_checklicense( 'simscape_battery' )
error( message( 'physmod:battery:license:MissingLicense' ) );
end 

obj = obj.updateColor;
if isempty( namedArgs.ParallelAssembly )
obj.ParallelAssembly = simscape.battery.builder.ParallelAssembly(  );
else 
obj.ParallelAssembly = namedArgs.ParallelAssembly;
end 

obj.BalancingStrategy = namedArgs.BalancingStrategy;
obj.AmbientThermalPath = namedArgs.AmbientThermalPath;
obj.CoolantThermalPath = namedArgs.CoolantThermalPath;
obj.CoolingPlate = namedArgs.CoolingPlate;
obj.ModelResolution = namedArgs.ModelResolution;
obj.InterParallelAssemblyGap = namedArgs.InterParallelAssemblyGap;
obj.MassFactor = namedArgs.MassFactor;
obj.StackingAxis = namedArgs.StackingAxis;
obj.NumSeriesAssemblies = namedArgs.NumSeriesAssemblies;
obj.SeriesGrouping = namedArgs.SeriesGrouping;
obj.ParallelGrouping = namedArgs.ParallelGrouping;
obj.Position = namedArgs.Position;
obj.MassFactor = namedArgs.MassFactor;
obj.Name = namedArgs.Name;
obj.BlockType = "ModuleType1";
obj.NonCellResistance = namedArgs.NonCellResistance;
end 

function obj = set.NumSeriesAssemblies( obj, val )
obj.NumSeriesAssembliesInternal = val;


obj = obj.updateLayout;


if obj.NumSeriesAssembliesInternal ~= all( obj.SeriesGrouping ) && strcmp( obj.ModelResolution, "Lumped" )
obj.SeriesGroupingInternal = obj.NumSeriesAssembliesInternal;
obj.ParallelGroupingInternal = 1;
elseif obj.NumSeriesAssembliesInternal ~= sum( obj.SeriesGrouping ) && strcmp( obj.ModelResolution, "Detailed" )
obj.SeriesGroupingInternal = ones( 1, obj.NumSeriesAssembliesInternal );
obj.ParallelGroupingInternal = obj.ParallelAssembly.NumParallelCells * ones( 1, obj.NumSeriesAssembliesInternal );
elseif obj.NumSeriesAssembliesInternal ~= sum( obj.SeriesGrouping ) && strcmp( obj.ModelResolution, "Grouped" )
obj.SeriesGroupingInternal = obj.NumSeriesAssembliesInternal;
obj.ParallelGroupingInternal = 1;
end 
end 

function value = get.NumSeriesAssemblies( obj )
value = obj.NumSeriesAssembliesInternal;
end 

function obj = set.BalancingStrategy( obj, val )
obj.BalancingStrategyInternal = val;
obj.ParallelAssemblyInternal.BalancingStrategy = val;
end 

function value = get.BalancingStrategy( obj )
value = obj.BalancingStrategyInternal;
end 

function value = get.BlockType( obj )
value = obj.BlockTypeInternal;
end 

function obj = set.BlockType( obj, val )
obj.BlockTypeInternal = val;
end 

function obj = set.Name( obj, val )
try 
assert( isvarname( val ),  ...
message( "physmod:battery:builder:batteryclasses:IsNotVarName" ) );
catch me
throwAsCaller( me )
end 
obj.NameInternal = val;
end 

function value = get.Name( obj )
value = obj.NameInternal;
end 

function obj = set.NonCellResistance( obj, val )
obj.NonCellResistanceInternal = val;
end 

function value = get.NonCellResistance( obj )
value = obj.NonCellResistanceInternal;
end 

function obj = set.AmbientThermalPath( obj, val )
try 
assert( obj.ParallelAssembly.Cell.ThermalEffects ~= "omit" || strcmp( val, "" ),  ...
message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );
catch me
throwAsCaller( me )
end 
obj.AmbientThermalPathInternal = val;
obj.ParallelAssemblyInternal.AmbientThermalPath = val;
end 

function value = get.AmbientThermalPath( obj )
value = obj.AmbientThermalPathInternal;
end 

function obj = set.CoolantThermalPath( obj, val )
try 
assert( obj.ParallelAssembly.Cell.ThermalEffects ~= "omit" || strcmp( val, "" ),  ...
message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );
catch me
throwAsCaller( me )
end 
obj.CoolantThermalPathInternal = val;
obj.ParallelAssemblyInternal.CoolantThermalPath = val;
end 

function value = get.CoolantThermalPath( obj )
value = obj.CoolantThermalPathInternal;
end 

function obj = set.CoolingPlate( obj, val )
try 
assert( obj.ParallelAssembly.Cell.ThermalEffects ~= "omit" || any( strcmp( [ val ], "" ) ),  ...
message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );%#ok<NBRAK2>
assert( numel( val ) <= 2,  ...
message( "physmod:battery:builder:batteryclasses:InvalidCoolingPlateProperty", "2" ) )
assert( sum( double( strcmp( val, "Top" ) ) ) ~= 2 && sum( double( strcmp( val, "Bottom" ) ) ) ~= 2,  ...
message( "physmod:battery:builder:batteryclasses:RepeatedCoolingPlateLocation" ) )
catch me
throwAsCaller( me )
end 
obj.CoolingPlateInternal = val;
obj.ParallelAssemblyInternal.CoolingPlate = val;
end 

function value = get.CoolingPlate( obj )
value = obj.CoolingPlateInternal;
end 

function obj = set.Position( obj, val )
obj.PositionInternal = simscape.battery.builder.internal.Position( X = val( 1 ), Y = val( 2 ), Z = val( 3 ) );
obj = obj.updateParallelAssemblyPositions;
obj = obj.updatePoints;
end 

function value = get.Position( obj )
value = [ obj.PositionInternal.X, obj.PositionInternal.Y, obj.PositionInternal.Z ];
end 

function obj = set.MassFactor( obj, val )
obj.MassFactorInternal = val;
end 

function value = get.MassFactor( obj )
value = obj.MassFactorInternal;
end 

function obj = set.InterParallelAssemblyGap( obj, val )
if strcmp( class( val ), "double" )
warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueMeters" ) )
val = simscape.Value( val, "m" );
end 
simscape.mustBeCommensurateUnit( val, "m" )
try 
assert( value( val, "m" ) <= 0.1,  ...
message( "physmod:battery:builder:batteryclasses:HighInterParallelAssemblyGap", "0.1" ) );
assert( value( val, "m" ) > 0,  ...
message( "physmod:battery:builder:batteryclasses:InvalidInterParallelAssemblyGap" ) );
catch me
throwAsCaller( me )
end 
obj.InterParallelAssemblyGapInternal = val;
obj = obj.updateLayout;
end 

function value = get.InterParallelAssemblyGap( obj )
value = obj.InterParallelAssemblyGapInternal;
end 

function obj = set.StackingAxis( obj, val )
obj.StackingAxisInternal = val;
obj = obj.updateLayout;
end 

function value = get.StackingAxis( obj )
value = obj.StackingAxisInternal;
end 

function obj = set.ParallelAssembly( obj, val )
try 
assert( ~isequal( val, simscape.battery.builder.ParallelAssembly.empty(  ) ),  ...
message( "physmod:battery:builder:batteryclasses:EmptyParallelAssemblyProperty" ) );
catch me
throwAsCaller( me )
end 
if ~isempty( obj.ParallelAssembly )
try 
assert( strcmp( val.BalancingStrategy, obj.BalancingStrategy ),  ...
message( "physmod:battery:builder:batteryclasses:BalancingStrategyMismatchWithModule" ) );
assert( strcmp( val.AmbientThermalPath, obj.AmbientThermalPath ),  ...
message( "physmod:battery:builder:batteryclasses:AmbientThermalPathMismatchWithModule" ) );
assert( strcmp( val.CoolantThermalPath, obj.CoolantThermalPath ),  ...
message( "physmod:battery:builder:batteryclasses:CoolantThermalPathMismatchWithModule" ) );
assert( all( strcmp( val.CoolingPlate, obj.CoolingPlate ) ),  ...
message( "physmod:battery:builder:batteryclasses:CoolingPlateMismatchWithModule" ) );
catch me
throwAsCaller( me )
end 
end 
obj.ParallelAssemblyInternal = val;


if strcmp( obj.ModelResolution, "Detailed" )
obj.ParallelGrouping = obj.ParallelAssembly.NumParallelCells * ones( 1, obj.NumSeriesAssembliesInternal );
end 


if strcmp( obj.ModelResolution, "Grouped" )
obj.ParallelAssemblyInternal.ModelResolution = "Lumped";
else 
obj.ParallelAssemblyInternal.ModelResolution = obj.ModelResolution;
end 


obj = obj.updateLayout;
end 

function value = get.ParallelAssembly( obj )
value = obj.ParallelAssemblyInternal;
end 

function obj = set.ModelResolution( obj, val )
obj.ModelResolutionInternal = val;
if strcmp( obj.ModelResolutionInternal, "Lumped" ) || strcmp( obj.ModelResolutionInternal, "Grouped" )
obj.SeriesGroupingInternal = obj.NumSeriesAssemblies;
obj.ParallelGroupingInternal = 1;
obj.ParallelAssemblyInternal.ModelResolution = "Lumped";
elseif strcmp( obj.ModelResolutionInternal, "Detailed" )
obj.SeriesGroupingInternal = ones( 1, obj.NumSeriesAssemblies );
obj.ParallelGroupingInternal = obj.ParallelAssembly.NumParallelCells * ones( 1, obj.NumSeriesAssemblies );
obj.ParallelAssemblyInternal.ModelResolution = "Detailed";
else 
end 
end 

function value = get.ModelResolution( obj )
value = obj.ModelResolutionInternal;
end 

function val = get.SimulationStrategyPatchDefinition( obj )

if strcmp( obj.ParallelAssembly.Topology, "" )
val.faces = NaN;
val.vertices = NaN( 1, 2 );
val.facevertexcdata = NaN;
else 
switch obj.ModelResolution
case "Detailed"
val = obj.BatteryPatchDefinition;
case "Lumped"
[ Extent.X, Extent.Y, Extent.Z ] = deal( value( obj.XExtent, "m" ), value( obj.YExtent, "m" ), value( obj.ZExtent, "m" ) );
thisPosition = obj.PositionInternal;
val = obj.getRectangularPrismDimensions( Extent, thisPosition );
case "Grouped"
numSimulatedPSet = length( obj.SeriesGrouping );
hardwarePSets = 1:1:obj.NumSeriesAssemblies;
simulatedVSHardwarePSets = [  ];
for simPSetIdx = 1:numSimulatedPSet
if simPSetIdx == 1
simulatedVSHardwarePSets = [ simulatedVSHardwarePSets, simPSetIdx * ones( 1, length( find( obj.SeriesGrouping( simPSetIdx ) >= hardwarePSets ) ) ) ];%#ok<AGROW>
else 
simulatedVSHardwarePSets = [ simulatedVSHardwarePSets, simPSetIdx * ones( 1, length( find( ( obj.SeriesGrouping( simPSetIdx - 1 ) < hardwarePSets ) & ( obj.SeriesGrouping( simPSetIdx ) + obj.SeriesGrouping( simPSetIdx - 1 ) >= hardwarePSets ) ) ) ) ];%#ok<AGROW>
end 
end 
SimStrategyPatch = struct( "faces", double.empty( 0, 4 ), "vertices", double.empty( 0, 3 ), "facevertexcdata", double.empty( 0, 1 ) );
for simulatedPsetIdx = 1:numSimulatedPSet
clear groupedPatch
switch obj.SeriesGrouping( simulatedPsetIdx )
case 1
switch obj.ParallelGrouping( simulatedPsetIdx )
case 1
pSetIndex = hardwarePSets( simulatedPsetIdx == simulatedVSHardwarePSets );
thesePoints = [ obj.ParallelAssemblies( hardwarePSets( simulatedPsetIdx == simulatedVSHardwarePSets ) ).CellPoints.Points ];
thisPosition = obj.ParallelAssemblies( pSetIndex( 1 ) ).PositionInternal;
if strcmp( obj.StackingAxis, "Y" )
thisPosition.X = obj.ParallelAssemblies( pSetIndex( 1 ) ).PositionInternal.X;
elseif strcmp( obj.StackingAxis, "X" )
thisPosition.Y = obj.ParallelAssemblies( pSetIndex( 1 ) ).PositionInternal.Y;
end 
[ Extent.X, Extent.Y, Extent.Z ] = deal( max( [ thesePoints.XData ], [  ], "all" ) - min( [ thesePoints.XData ], [  ], "all" ) + thisPosition.X,  ...
min( [ thesePoints.YData ], [  ], "all" ) - max( [ thesePoints.YData ], [  ], "all" ) + thisPosition.Y,  ...
max( [ thesePoints.ZData ], [  ], "all" ) - min( [ thesePoints.ZData ], [  ], "all" ) + thisPosition.Z );
groupedPatch = obj.getRectangularPrismDimensions( Extent, thisPosition );
case obj.ParallelAssembly.NumParallelCells
pSetIndex = hardwarePSets( simulatedPsetIdx == simulatedVSHardwarePSets );
pSetPatch = struct( "faces", double.empty( 0, 4 ), "vertices", double.empty( 0, 3 ), "facevertexcdata", double.empty( 0, 1 ) );
for cellIdx = 1:obj.ParallelAssembly.NumParallelCells
thisPosition = obj.ParallelAssemblies( pSetIndex ).CellPositions( cellIdx );
thesePoints = simscape.battery.builder.internal.Points( thisPosition.X + obj.ParallelAssembly.Cell.Points.XData,  ...
thisPosition.Y + obj.ParallelAssembly.Cell.Points.YData,  ...
thisPosition.Z + obj.ParallelAssembly.Cell.Points.ZData );
cdata = ones( size( thesePoints.ZData ) );
cellPatch = surf2patch( thesePoints.XData, thesePoints.YData, thesePoints.ZData, cdata );
if cellIdx == 1
maxFaceValue = 0;
else 
maxFaceValue = max( pSetPatch.faces( : ) );
end 
pSetPatch.faces = [ pSetPatch.faces;cellPatch.faces + maxFaceValue ];
pSetPatch.vertices = [ pSetPatch.vertices;cellPatch.vertices ];
pSetPatch.facevertexcdata = [ pSetPatch.facevertexcdata;cellPatch.facevertexcdata ];
clear cellPatch maxFaceValue
end 
groupedPatch = pSetPatch;
end 
otherwise 


pSetIndex = hardwarePSets( simulatedPsetIdx == simulatedVSHardwarePSets );
[ concadenatedPoints ] = [ obj.ParallelAssemblies( hardwarePSets( simulatedPsetIdx == simulatedVSHardwarePSets ) ).CellPoints ];
thesePoints = [ concadenatedPoints.Points ];
thisPosition = obj.ParallelAssemblies( pSetIndex( 1 ) ).PositionInternal( 1 );
if strcmp( obj.StackingAxis, "Y" )
thisPosition.X = obj.ParallelAssemblies( 1 ).PositionInternal( 1 ).X;
elseif strcmp( obj.StackingAxis, "X" )
thisPosition.Y = obj.ParallelAssemblies( 1 ).PositionInternal( 1 ).Y;
end 
[ Extent.X, Extent.Y, Extent.Z ] = deal( max( [ thesePoints.XData ], [  ], "all" ) - min( [ thesePoints.XData ], [  ], "all" ) + thisPosition.X,  ...
min( [ thesePoints.YData ], [  ], "all" ) - max( [ thesePoints.YData ], [  ], "all" ) + thisPosition.Y,  ...
max( [ thesePoints.ZData ], [  ], "all" ) - min( [ thesePoints.ZData ], [  ], "all" ) + thisPosition.Z );
groupedPatch = obj.getRectangularPrismDimensions( Extent, thisPosition );
end 

if simulatedPsetIdx == 1
maxFaceValue = 0;
else 
maxFaceValue = max( SimStrategyPatch.faces( : ) );
end 
SimStrategyPatch.faces = [ SimStrategyPatch.faces;groupedPatch.faces + maxFaceValue ];
SimStrategyPatch.vertices = [ SimStrategyPatch.vertices;groupedPatch.vertices ];
SimStrategyPatch.facevertexcdata = [ SimStrategyPatch.facevertexcdata;groupedPatch.facevertexcdata ];
clear maxFaceValue
end 
val = SimStrategyPatch;
end 
end 
end 

function value = get.Columns( obj )

if isempty( obj.ParallelAssembly.Cell.Format )
else 
value = ceil( obj.ParallelAssembly.NumParallelCells * obj.NumSeriesAssemblies / obj.ParallelAssembly.Rows );
end 
end 

function obj = set.SeriesGrouping( obj, val )
if isempty( val )
else 
try 
assert( sum( val ) == obj.NumSeriesAssemblies,  ...
message( "physmod:battery:builder:batteryclasses:SeriesGroupingNumSeriesMismatch" ) );
catch me
throwAsCaller( me )
end 
end 
if isempty( val ) && strcmp( obj.ModelResolutionInternal, "Lumped" )
obj.SeriesGroupingInternal = obj.NumSeriesAssemblies;
elseif isempty( val ) && strcmp( obj.ModelResolutionInternal, "Detailed" )
obj.SeriesGroupingInternal = ones( 1, obj.NumSeriesAssemblies );
elseif isempty( val ) && strcmp( obj.ModelResolutionInternal, "Grouped" )
obj.SeriesGroupingInternal = ones( 1, length( obj.ParallelGroupingInternal ) );
else 
obj.SeriesGroupingInternal = val;
end 

if length( obj.SeriesGrouping ) == 1 && ~isempty( val )
obj.ModelResolutionInternal = "Lumped";
elseif length( obj.SeriesGrouping ) == obj.NumSeriesAssemblies && ~isempty( val )
if numel( obj.ParallelGroupingInternal ) == numel( obj.ParallelAssembly.NumParallelCells * ones( 1, length( obj.SeriesGrouping ) ) )
if all( obj.ParallelGroupingInternal == obj.ParallelAssembly.NumParallelCells * ones( 1, length( obj.SeriesGrouping ) ) )
obj.ModelResolutionInternal = "Detailed";
end 
else 
obj.ModelResolutionInternal = "Grouped";
end 
elseif length( obj.SeriesGrouping ) < obj.NumSeriesAssemblies ...
 && length( obj.SeriesGrouping ) > 1 && ~isempty( val )
obj.ModelResolutionInternal = "Grouped";
else 
end 

if length( obj.SeriesGrouping ) ~= length( obj.ParallelGrouping ) && strcmp( obj.ModelResolution, "Grouped" )
obj.ParallelGroupingInternal = ones( 1, length( obj.SeriesGrouping ) );
elseif length( obj.SeriesGrouping ) ~= length( obj.ParallelGrouping ) && strcmp( obj.ModelResolution, "Detailed" )
obj.ParallelGroupingInternal = obj.ParallelAssembly.NumParallelCells * ones( 1, length( obj.SeriesGrouping ) );
elseif length( obj.SeriesGrouping ) ~= length( obj.ParallelGrouping ) && strcmp( obj.ModelResolution, "Lumped" )
obj.ParallelGroupingInternal = ones( 1, length( obj.SeriesGrouping ) );
end 
end 

function value = get.SeriesGrouping( obj )
value = obj.SeriesGroupingInternal;
end 

function obj = set.ParallelGrouping( obj, val )
if ~isempty( val )
try 
assert( ParallelGroupingValidation( obj, val ) ~= 0,  ...
message( "physmod:battery:builder:batteryclasses:ParallelGroupingNumParallelMismatch" ) );
assert( length( val ) <= obj.NumSeriesAssemblies,  ...
message( "physmod:battery:builder:batteryclasses:ParallelGroupingLengthMismatch" ) );
catch me
throwAsCaller( me )
end 
obj.ParallelGroupingInternal = val;
elseif isempty( val ) && strcmp( obj.ModelResolutionInternal, "Lumped" )
obj.ParallelGroupingInternal = 1;
elseif isempty( val ) && strcmp( obj.ModelResolutionInternal, "Detailed" )
obj.ParallelGroupingInternal = obj.ParallelAssembly.NumParallelCells * ones( 1, obj.NumSeriesAssemblies );
elseif isempty( val ) && strcmp( obj.ModelResolutionInternal, "Grouped" )
obj.ParallelGroupingInternal = ones( 1, length( obj.SeriesGrouping ) );
end 

if length( obj.ParallelGrouping ) == 1 && ~isempty( val ) && ~strcmp( obj.ModelResolution, "Detailed" )
obj.ModelResolutionInternal = "Lumped";
elseif length( obj.ParallelGrouping ) < obj.NumSeriesAssemblies ...
 && length( obj.ParallelGrouping ) > 1
obj.ModelResolutionInternal = "Grouped";
elseif length( obj.ParallelGrouping ) == obj.NumSeriesAssemblies &&  ...
strcmp( obj.ModelResolution, "Grouped" ) && length( obj.SeriesGrouping ) < obj.NumSeriesAssemblies && all( obj.ParallelGrouping == obj.ParallelAssembly.NumParallelCells )
obj.SeriesGroupingInternal = [ obj.NumSeriesAssemblies - ( length( obj.ParallelGrouping ) - 1 ), ones( 1, length( obj.ParallelGrouping ) - 1 ) ];
obj.ModelResolutionInternal = "Detailed";
elseif length( obj.ParallelGrouping ) == obj.NumSeriesAssemblies && all( obj.ParallelGrouping == obj.ParallelAssembly.NumParallelCells * ones( 1, obj.NumSeriesAssemblies ) ) ...
 && length( obj.ParallelGrouping ) == length( obj.SeriesGrouping ) && obj.NumSeriesAssemblies ~= 1 && obj.ParallelAssembly.NumParallelCells ~= 1
obj.ModelResolutionInternal = "Detailed";
end 

if length( obj.ParallelGrouping ) ~= length( obj.SeriesGrouping ) ...
 && strcmp( obj.ModelResolutionInternal, "Grouped" )
obj.SeriesGroupingInternal = [ obj.NumSeriesAssemblies - ( length( obj.ParallelGrouping ) - 1 ), ones( 1, length( obj.ParallelGrouping ) - 1 ) ];
end 

if length( val ) > 1
try 
assert( ParallelGroupingToSeriesGroupingValidation( obj, val ) ~= 0,  ...
message( "physmod:battery:builder:batteryclasses:ParallelGroupingSeriesGroupingMismatch" ) );
catch me
throwAsCaller( me )
end 
end 
end 

function value = get.ParallelGrouping( obj )
value = obj.ParallelGroupingInternal;
end 

function value = get.ThermalBoundaryConditions( obj )
Faces = [ "Top", "Bottom" ];
value = [  ];
if isempty( obj.AmbientThermalPath ) && isempty( obj.CoolantThermalPath ) ...
 && isempty( obj.CoolingPlate )
value.Ambient = "Adiabatic";
value.Coolant = "Adiabatic";
for faceIdx = 1:2
value.( Faces{ faceIdx } ) = "Adiabatic";
end 
return 
else 
if ( ~isempty( obj.AmbientThermalPath ) )
value.Ambient = obj.AmbientThermalPath;
end 
if isfield( value, "Ambient" )
if strcmp( value.Ambient, "" )
value.Ambient = "Adiabatic";
end 
else 
value.Ambient = "Adiabatic";
end 
if ( ~isempty( obj.CoolantThermalPath ) )
value.Coolant = obj.CoolantThermalPath;
end 
if isfield( value, "Coolant" )
if strcmp( value.Coolant, "" )
value.Coolant = "Adiabatic";
end 
else 
value.Coolant = "Adiabatic";
end 
for faceIdx = 1:2
if ( ~isempty( obj.CoolingPlate ) )
if any( contains( obj.CoolingPlate, ( Faces{ faceIdx } ) ) )
value.( Faces{ faceIdx } ).CoolingPlate = "CoolingPlate";
end 
end 
if ~isfield( value, ( Faces{ faceIdx } ) )
value.( Faces{ faceIdx } ) = "Adiabatic";
end 
end 
end 
end 

function val = get.ThermalNodes( obj )
if strcmp( obj.ParallelAssembly.Topology, "" )
val.Locations = [  ];
val.Dimensions = [  ];
val.NumNodes = [  ];
else 

TotCellIdx = 1;
TotGroupedModelIdx = 1;
InitialGroupedCellIdx = 1;
EndGroupedCellIdx = 0;
GroupedCellNodeDimensions = zeros( sum( obj.ParallelGrouping ), 2 );
GroupedCellNodeLocations = zeros( sum( obj.ParallelGrouping ), 2 );
CellNodeLocations = zeros( obj.NumSeriesAssemblies * obj.ParallelAssembly.NumParallelCells, 2 );
CellNodeDimensions = zeros( obj.NumSeriesAssemblies * obj.ParallelAssembly.NumParallelCells, 2 );
for ParallelAssemblyIdx = 1:obj.NumSeriesAssemblies
for CellIdx = 1:obj.ParallelAssembly.NumParallelCells
thisPosition = obj.ParallelAssemblyRelativePositions( ParallelAssemblyIdx ).ParallelAssembly( CellIdx );
thesePoints = obj.ParallelAssemblies( ParallelAssemblyIdx ).CellPoints( CellIdx ).Points;
CellNodeLocations( TotCellIdx, : ) = [ thisPosition.X, abs( thisPosition.Y ) ];
CellNodeDimensions( TotCellIdx, : ) = [ ( max( max( abs( thesePoints.XData ) ) ) - min( min( abs( thesePoints.XData ) ) ) ), ( max( max( abs( thesePoints.YData ) ) ) - min( min( abs( thesePoints.YData ) ) ) ) ];
TotCellIdx = TotCellIdx + 1;
end 
end 

if strcmp( obj.ModelResolution, "Detailed" )


GroupedCellNodeDimensions = CellNodeDimensions;
GroupedCellNodeLocations = CellNodeLocations;
elseif strcmp( obj.ModelResolution, "Grouped" )

Idx = 1;
for i = 1:sum( obj.ParallelGrouping )
EndGroupedCellIdx = obj.SeriesGrouping( Idx ) * (  - obj.ParallelGrouping( Idx ) + ( obj.ParallelAssembly.NumParallelCells + 1 ) ) + EndGroupedCellIdx;
if obj.StackingAxis == "X"
GroupedCellNodeDimensions( TotGroupedModelIdx, : ) = [ value( obj.XExtent, "m" ) - obj.Position( 1 ),  ...
( abs( value( obj.YExtent, "m" ) ) - obj.Position( 2 ) ) * obj.SeriesGrouping( Idx ) / sum( obj.SeriesGrouping ) ];
GroupedCellNodeLocations( TotGroupedModelIdx, : ) = [ mean( CellNodeLocations( InitialGroupedCellIdx:EndGroupedCellIdx, 1 ) ),  ...
mean( CellNodeLocations( InitialGroupedCellIdx:EndGroupedCellIdx, 2 ) ) ];
else 
GroupedCellNodeDimensions( TotGroupedModelIdx, : ) = [ ( abs( value( obj.YExtent, "m" ) ) - obj.Position( 2 ) ) * obj.SeriesGrouping( Idx ) / sum( obj.SeriesGrouping ),  ...
value( obj.XExtent, "m" ) - obj.Position( 1 ) ];
GroupedCellNodeLocations( TotGroupedModelIdx, : ) = [ mean( CellNodeLocations( InitialGroupedCellIdx:EndGroupedCellIdx, 1 ) ),  ...
mean( CellNodeLocations( InitialGroupedCellIdx:EndGroupedCellIdx, 2 ) ) ];
end 
TotGroupedModelIdx = TotGroupedModelIdx + 1;
InitialGroupedCellIdx = EndGroupedCellIdx + 1;
if obj.ParallelGrouping( Idx ) == 1
Idx = Idx + 1;
else 
end 
end 
elseif strcmp( obj.ModelResolution, "Lumped" )
GroupedCellNodeDimensions( TotGroupedModelIdx, : ) = [ abs( value( obj.XExtent, "m" ) - obj.PositionInternal.X ),  ...
abs( value( obj.YExtent, "m" ) - obj.PositionInternal.Y ) ];
GroupedCellNodeLocations( TotGroupedModelIdx, : ) = [ mean( CellNodeLocations( :, 1 ) ),  ...
mean( CellNodeLocations( :, 2 ) ) ];
end 
if any( contains( obj.CoolingPlate, "Top" ) )
val.Top.Locations = GroupedCellNodeLocations;
val.Top.Dimensions = GroupedCellNodeDimensions;
val.Top.NumNodes = length( GroupedCellNodeLocations( :, 1 ) );
end 
if any( contains( obj.CoolingPlate, "Bottom" ) )
val.Bottom.Locations = GroupedCellNodeLocations;
val.Bottom.Dimensions = GroupedCellNodeDimensions;
val.Bottom.NumNodes = length( GroupedCellNodeLocations( :, 1 ) );
end 
if ~any( contains( obj.CoolingPlate, "Top" ) ) || ~any( contains( obj.CoolingPlate, "Bottom" ) )
val.Locations = GroupedCellNodeLocations;
val.Dimensions = GroupedCellNodeDimensions;
val.NumNodes = length( GroupedCellNodeLocations( :, 1 ) );
end 
end 
end 

function value = get.ParallelAssemblyRelativePositions( obj )
if obj.PositionInternal.X == 0 &&  ...
obj.PositionInternal.Y == 0 &&  ...
obj.PositionInternal.Z == 0
for ParallelAssemblyIdx = 1:obj.NumSeriesAssemblies
value( ParallelAssemblyIdx ).ParallelAssembly = obj.ParallelAssemblies( ParallelAssemblyIdx ).CellCenterPositions;%#ok<AGROW> 
end 
else 
for ParallelAssemblyIdx = 1:obj.NumSeriesAssemblies
for CellIdx = 1:obj.NumParallelCells
thisPosition = obj.ParallelAssemblies( parallelAssemblyIdx ).CellCenterPositions( cellIdx );
ParAssemblyRelPos( ParallelAssemblyIdx ).ParallelAssembly( CellIdx ) = simscape.battery.builder.internal.Position( X = thisPosition.X - obj.PositionInternal.X,  ...
Y = thisPosition.Y - obj.PositionInternal.Y, Z = thisPosition.Z - obj.PositionInternal.Z );%#ok<AGROW>
end 
end 
value = ParAssemblyRelPos;
end 
end 

function val = get.PackagingVolume( obj )
if isempty( obj.XExtent )
val = simscape.Value( [  ], "m^3" );
else 
[ TheseParallelAssemblyPoints ] = [ obj.ParallelAssemblies.CellPoints ];
thesePoints = [ TheseParallelAssemblyPoints.Points ];
[ X, Y, Z ] = deal( max( [ thesePoints.XData ], [  ], "all" ) - min( [ thesePoints.XData ], [  ], "all" ),  ...
min( [ thesePoints.YData ], [  ], "all" ) - max( [ thesePoints.YData ], [  ], "all" ),  ...
max( [ thesePoints.ZData ], [  ], "all" ) - min( [ thesePoints.ZData ], [  ], "all" ) );
val = simscape.Value( abs( X * Y * Z ), "m^3" );
end 
end 

function value = get.CumulativeMass( obj )
value = obj.ParallelAssembly.CumulativeMass * obj.NumSeriesAssemblies * obj.MassFactor;
end 

function value = get.SimulationToHardwareMapping( obj )
BatteryTypes = [ "Module", "ParallelAssembly", "Cell", "Model" ];
CellIndex = [  ];
ParallelAssemblyIndex = [  ];
for pSetIdx = 1:obj.NumSeriesAssemblies
CellIndex = [ CellIndex;( 1:1:obj.ParallelAssembly.NumParallelCells )' ];%#ok<AGROW>
ParallelAssemblyIndex = [ ParallelAssemblyIndex;pSetIdx * ones( length( ( 1:1:obj.ParallelAssembly.NumParallelCells )' ), 1 ) ];%#ok<AGROW>
end 
moduleIndex = ones( length( ParallelAssemblyIndex ), 1 );
SimulationToHardware( :, 1 ) = moduleIndex;
SimulationToHardware( :, 2 ) = ParallelAssemblyIndex;
SimulationToHardware( :, 3 ) = CellIndex;
switch obj.ModelResolution
case "Lumped"
SimulationToHardware( :, 4 ) = ones( length( ParallelAssemblyIndex ), 1 );
case "Detailed"
SimulationToHardware( :, 4 ) = ( 1:1:length( ParallelAssemblyIndex ) )';
case "Grouped"
NumSimulatedPSets = length( obj.SeriesGrouping );
hardwarePSets = 1:1:obj.NumSeriesAssemblies;
simulatedVSHardwarePSets = [  ];
for simPSetIdx = 1:NumSimulatedPSets
if simPSetIdx == 1
simulatedVSHardwarePSets = [ simulatedVSHardwarePSets, simPSetIdx * ones( 1, length( find( obj.SeriesGrouping( simPSetIdx ) >= hardwarePSets ) ) ) ];%#ok<AGROW>
else 
simulatedVSHardwarePSets = [ simulatedVSHardwarePSets, simPSetIdx * ones( 1, length( find( ( obj.SeriesGrouping( simPSetIdx - 1 ) < hardwarePSets ) & ( obj.SeriesGrouping( simPSetIdx ) + obj.SeriesGrouping( simPSetIdx - 1 ) >= hardwarePSets ) ) ) ) ];%#ok<AGROW>
end 
end 
ModelVec = [  ];
NumOfModels = 1;
for simPSetIdx = 1:NumSimulatedPSets
pSetIndex = hardwarePSets( simPSetIdx == simulatedVSHardwarePSets );
switch obj.SeriesGrouping( simPSetIdx )
case 1
switch obj.ParallelGrouping( simPSetIdx )
case 1
ModelVec = [ ModelVec;( NumOfModels ) * ones( obj.ParallelAssembly.NumParallelCells, 1 ) ];%#ok<AGROW>
NumOfModels = NumOfModels + 1;
case obj.ParallelAssembly.NumParallelCells
ModelVec = [ ModelVec;( NumOfModels:1:obj.ParallelAssembly.NumParallelCells + NumOfModels - 1 )' ];%#ok<AGROW>
NumOfModels = NumOfModels + obj.ParallelAssembly.NumParallelCells;
end 
otherwise 
ModelVec = [ ModelVec;( NumOfModels ) * ones( obj.ParallelAssembly.NumParallelCells * length( pSetIndex ), 1 ) ];%#ok<AGROW>
NumOfModels = NumOfModels + 1;
end 
end 
SimulationToHardware( :, 4 ) = ModelVec;
end 

value = array2table( SimulationToHardware );
value.Properties.VariableNames = BatteryTypes;
end 

function value = get.NumModels( obj )
value = obj.SimulationToHardwareMapping.Model( end  );
end 

end 


methods ( Hidden )

function value = getExtent( obj, axisExtentName )
if strcmp( obj.ParallelAssembly.Cell.Format, "" )
value = simscape.Value( [  ], "m" );
else 
parallelAssemblyExtent = zeros( obj.NumSeriesAssemblies, 1 );
for parallelAssemblyIdx = 1:( obj.NumSeriesAssemblies )
allPoints = [ obj.ParallelAssemblies( parallelAssemblyIdx ).CellPoints.Points ];
if strcmp( axisExtentName, "YData" )
parallelAssemblyExtent( parallelAssemblyIdx ) = min( min( ( [ allPoints.( axisExtentName ) ] ) ) );
else 
parallelAssemblyExtent( parallelAssemblyIdx ) = max( max( abs( [ allPoints.( axisExtentName ) ] ) ) );
end 
end 
if strcmp( axisExtentName, "YData" )
value = simscape.Value( min( parallelAssemblyExtent ), "m" );
else 
value = simscape.Value( max( parallelAssemblyExtent ), "m" );
end 
end 
end 
end 

methods ( Access = private )

function obj = updateLayout( obj )
obj = getLayoutArray( obj );


obj = obj.updateColor;
obj = obj.updateParallelAssemblyPositions;
obj = obj.updatePoints;
end 

function obj = updateParallelAssemblyPositions( obj )
obj.ParallelAssemblies = repmat( obj.ParallelAssembly, obj.NumSeriesAssemblies, 1 );
if strcmp( obj.ParallelAssembly.Topology, "" )
else 
parallelAssemblyGap = value( obj.InterParallelAssemblyGap, "m" );
if isempty( obj.PositionInternal )
[ modulePosition.X, modulePosition.Y, modulePosition.Z ] = deal( 0, 0, 0 );
else 
modulePosition = obj.PositionInternal;
end 

if strcmp( obj.ParallelAssembly.Topology, "Hexagonal" ) &&  ...
( ceil( obj.ParallelAssembly.NumParallelCells / obj.ParallelAssembly.Rows ) == round( obj.ParallelAssembly.NumParallelCells / obj.ParallelAssembly.Rows - 1e-3 ) ) ...
 && obj.ParallelAssembly.Rows ~= 1
if strcmp( obj.StackingAxis, obj.ParallelAssembly.StackingAxis )
pSetOffset = value( obj.ParallelAssembly.Cell.Geometry.Radius, "m" ) + parallelAssemblyGap / 2;
else 
if mod( obj.ParallelAssembly.NumParallelCells, obj.ParallelAssembly.Rows ) > 0
pSetOffset = 0;
else 
pSetOffset = ( 2 * value( obj.ParallelAssembly.Cell.Geometry.Radius, "m" ) ) * ( 1 - sqrt( 3 ) / 2 );
end 
end 
else 
pSetOffset = 0;
end 

[ prevParallelAssemblyExtend.X, prevParallelAssemblyExtend.Y, prevParallelAssemblyExtend.Z ] = deal( modulePosition.X, modulePosition.Y, modulePosition.Z );
for parallelAssemblyIdx = 1:obj.NumSeriesAssemblies
gapFactor = double( parallelAssemblyIdx > 1 );
if strcmp( obj.StackingAxis, "Y" )
thisX = modulePosition.X;
thisY =  - ( parallelAssemblyGap * gapFactor ) + prevParallelAssemblyExtend.Y + pSetOffset * gapFactor;
elseif strcmp( obj.StackingAxis, "X" )
thisX = parallelAssemblyGap * gapFactor + prevParallelAssemblyExtend.X - pSetOffset * gapFactor;
thisY = modulePosition.Y;
end 
thisZ = modulePosition.Z;
obj.ParallelAssemblies( parallelAssemblyIdx ).Position = [ thisX, thisY, thisZ ];
prevParallelAssemblyExtend.X = value( obj.ParallelAssemblies( parallelAssemblyIdx ).XExtent, 'm' );
prevParallelAssemblyExtend.Y = value( obj.ParallelAssemblies( parallelAssemblyIdx ).YExtent, 'm' );
prevParallelAssemblyExtend.Z = value( obj.ParallelAssemblies( parallelAssemblyIdx ).ZExtent, 'm' );
end 
end 
end 

function obj = updatePoints( obj )
if isempty( obj.ParallelAssembly.Cell.Geometry )
obj.BatteryPatchDefinition.faces = NaN;
obj.BatteryPatchDefinition.vertices = NaN( 1, 2 );
obj.BatteryPatchDefinition.facevertexcdata = NaN;
else 
modulePatch = struct( "faces", double.empty( 0, 4 ), "vertices", double.empty( 0, 3 ), "facevertexcdata", double.empty( 0, 1 ) );
for parallelAssemblyIdx = 1:obj.NumSeriesAssemblies
if parallelAssemblyIdx > 1
maxFaceValue = max( modulePatch.faces( : ) );
modulePatch.faces = [ modulePatch.faces;obj.ParallelAssemblies( parallelAssemblyIdx ).BatteryPatchDefinition.faces + maxFaceValue ];
modulePatch.vertices = [ modulePatch.vertices;obj.ParallelAssemblies( parallelAssemblyIdx ).BatteryPatchDefinition.vertices ];
modulePatch.facevertexcdata = [ modulePatch.facevertexcdata;obj.ParallelAssemblies( parallelAssemblyIdx ).BatteryPatchDefinition.facevertexcdata ];

elseif parallelAssemblyIdx == 1
modulePatch.faces = [ obj.ParallelAssemblies( parallelAssemblyIdx ).BatteryPatchDefinition.faces ];
modulePatch.vertices = [ obj.ParallelAssemblies( parallelAssemblyIdx ).BatteryPatchDefinition.vertices ];
modulePatch.facevertexcdata = [ obj.ParallelAssemblies( parallelAssemblyIdx ).BatteryPatchDefinition.facevertexcdata ];
else 
end 
end 
obj.BatteryPatchDefinition = modulePatch;
end 
end 

function obj = updateColor( obj )
for parallelAssemblyIdx = 1:obj.NumSeriesAssemblies
obj.ParallelAssemblyColors( parallelAssemblyIdx, 1 ).CellColors = repmat( simscape.battery.builder.internal.StateVariable, obj.ParallelAssembly.NumParallelCells, 1 );
end 
end 

function obj = getLayoutArray( obj )









obj.CellNumbering = [  ];
thisLayout = reshape( 1:obj.ParallelAssembly.Rows * ceil( obj.ParallelAssembly.NumParallelCells / obj.ParallelAssembly.Rows ),  ...
obj.ParallelAssembly.Rows,  ...
ceil( obj.ParallelAssembly.NumParallelCells / obj.ParallelAssembly.Rows ) );


if strcmp( obj.ParallelAssembly.Cell.Format, "" )
if obj.NumSeriesAssemblies > 1
OriginalLayout = thisLayout;
for pSetIdx = 1:( obj.NumSeriesAssemblies - 1 )
thisLayout = [ thisLayout, thisLayout( end , end  ) + OriginalLayout ];%#ok<AGROW>
end 
for pSetIdx = 1:( obj.NumSeriesAssemblies )
obj.CellNumbering( pSetIdx ).ParallelAssembly = pSetIdx;
obj.CellNumbering( pSetIdx ).Cells = 1:1:obj.ParallelAssembly.NumParallelCells;
end 
elseif obj.NumSeriesAssemblies == 1
obj.CellNumbering( 1 ).ParallelAssembly = 1;
obj.CellNumbering( 1 ).Cells = 1:1:obj.ParallelAssembly.NumParallelCells;
OriginalLayout = thisLayout;
thisLayout = OriginalLayout;
end 
elseif strcmp( obj.ParallelAssembly.Cell.Format, "Cylindrical" ) || strcmp( obj.ParallelAssembly.Cell.Format, "Prismatic" )
MissingNoCells = mod( obj.ParallelAssembly.NumParallelCells, obj.ParallelAssembly.Rows );
if MissingNoCells ~= 0
missingNoCellsIdx = obj.ParallelAssembly.NumParallelCells - MissingNoCells + 1;
endColumnLayout = round( linspace( missingNoCellsIdx, obj.ParallelAssembly.NumParallelCells, obj.ParallelAssembly.Rows ) );
endColumnLayout = obj.remainderCellLocFcn( obj, MissingNoCells, endColumnLayout );
thisLayout( :, end  ) = endColumnLayout;
obj.CellNumbering( 1 ).ParallelAssembly = 1;
obj.CellNumbering( 1 ).Cells = thisLayout;
if obj.NumSeriesAssemblies > 1
for pSetIdx = 1:( obj.NumSeriesAssemblies - 1 )
NoCellsInPreviousPset = sum( double( endColumnLayout == 0 ) );
prevMax = max( endColumnLayout );
endColumnLayout( endColumnLayout == 0 ) = prevMax + ( 1:NoCellsInPreviousPset );
thisLayout( :, end  ) = endColumnLayout;
missingNoCells_i = mod( obj.ParallelAssembly.NumParallelCells - NoCellsInPreviousPset, obj.ParallelAssembly.Rows );
firstColumn = endColumnLayout';
firstColumn( firstColumn <= prevMax ) = 0;
additionalColumns_i = ceil( ( obj.ParallelAssembly.NumParallelCells - NoCellsInPreviousPset ) / obj.ParallelAssembly.Rows );
interColumns = reshape( ( ( prevMax + NoCellsInPreviousPset ) + 1 ):( ( prevMax + NoCellsInPreviousPset ) + ( additionalColumns_i - 1 ) * obj.ParallelAssembly.Rows ), obj.ParallelAssembly.Rows, ( additionalColumns_i - 1 ) );
if isempty( interColumns )
missingNoCellsIdx = max( firstColumn ) + 1;
newEndColumnLayout = round( linspace( missingNoCellsIdx, obj.ParallelAssembly.NumParallelCells * ( pSetIdx + 1 ), obj.ParallelAssembly.Rows ) );
if missingNoCells_i == 0
else 
newEndColumnLayout = obj.remainderCellLocFcn( obj, missingNoCells_i, newEndColumnLayout );
end 
obj.CellNumbering( pSetIdx + 1 ).ParallelAssembly = pSetIdx + 1;
if all( firstColumn == 0 )
obj.CellNumbering( pSetIdx + 1 ).Cells = newEndColumnLayout';
else 
obj.CellNumbering( pSetIdx + 1 ).Cells = [ firstColumn, newEndColumnLayout' ];
end 
obj.CellNumbering( pSetIdx + 1 ).Cells( obj.CellNumbering( pSetIdx + 1 ).Cells > 0 ) = 1:1:obj.ParallelAssembly.NumParallelCells;
thisLayout = [ thisLayout, newEndColumnLayout' ];%#ok<AGROW>
else 
missingNoCellsIdx = interColumns( end , end  ) + 1;
newEndColumnLayout = round( linspace( missingNoCellsIdx, obj.ParallelAssembly.NumParallelCells * ( pSetIdx + 1 ), obj.ParallelAssembly.Rows ) );
if ( obj.ParallelAssembly.NumParallelCells - ( NoCellsInPreviousPset + length( interColumns( :, 1 ) ) * length( interColumns( 1, : ) ) ) ) == obj.ParallelAssembly.Rows
else 
newEndColumnLayout = obj.remainderCellLocFcn( obj, missingNoCells_i, newEndColumnLayout );
end 
obj.CellNumbering( pSetIdx + 1 ).ParallelAssembly = pSetIdx + 1;
if all( firstColumn == 0 )
obj.CellNumbering( pSetIdx + 1 ).Cells = [ interColumns, newEndColumnLayout' ];
else 
obj.CellNumbering( pSetIdx + 1 ).Cells = [ firstColumn, interColumns, newEndColumnLayout' ];
end 
obj.CellNumbering( pSetIdx + 1 ).Cells( obj.CellNumbering( pSetIdx + 1 ).Cells > 0 ) = 1:1:obj.ParallelAssembly.NumParallelCells;
thisLayout = [ thisLayout, interColumns, newEndColumnLayout' ];%#ok<AGROW>
end 
endColumnLayout = newEndColumnLayout;
end 
if sum( sum( thisLayout == obj.NumSeriesAssemblies * obj.ParallelAssembly.NumParallelCells ) ) == 0
thisLayout( end , end  ) = obj.NumSeriesAssemblies * obj.ParallelAssembly.NumParallelCells;
end 
else 
end 
else 
if obj.NumSeriesAssemblies > 1
obj.CellNumbering( 1 ).ParallelAssembly = 1;
obj.CellNumbering( 1 ).Cells = thisLayout;
OriginalLayout = thisLayout;
for pSetIdx = 1:( obj.NumSeriesAssemblies - 1 )
obj.CellNumbering( pSetIdx + 1 ).Cells = thisLayout( end , end  ) + OriginalLayout;
thisLayout = [ thisLayout, thisLayout( end , end  ) + OriginalLayout ];%#ok<AGROW>
obj.CellNumbering( pSetIdx + 1 ).Cells( obj.CellNumbering( pSetIdx + 1 ).Cells > 0 ) = 1:1:obj.ParallelAssembly.NumParallelCells;
obj.CellNumbering( pSetIdx + 1 ).ParallelAssembly = pSetIdx + 1;
end 
else 

end 
end 
elseif strcmp( obj.ParallelAssembly.Cell.Format, "Pouch" )
if obj.NumSeriesAssemblies > 1
OriginalLayout = thisLayout;
obj.CellNumbering( 1 ).ParallelAssembly = 1;
obj.CellNumbering( 1 ).Cells = thisLayout;
for pSetIdx = 1:( obj.NumSeriesAssemblies - 1 )
obj.CellNumbering( pSetIdx + 1 ).Cells = thisLayout( end , end  ) + OriginalLayout;
thisLayout = [ thisLayout, thisLayout( end , end  ) + OriginalLayout ];%#ok<AGROW>
obj.CellNumbering( pSetIdx + 1 ).Cells( obj.CellNumbering( pSetIdx + 1 ).Cells > 0 ) = 1:1:obj.ParallelAssembly.NumParallelCells;
obj.CellNumbering( pSetIdx + 1 ).ParallelAssembly = pSetIdx + 1;
end 
else 

end 
end 
obj.Layout = thisLayout;
end 

function passFailValidation = ParallelGroupingValidation( obj, val )
for simPSetIdx = 1:length( val )
if val( simPSetIdx ) == 1 || val( simPSetIdx ) == obj.ParallelAssembly.NumParallelCells
conditionalVec( simPSetIdx ) = 1;%#ok<AGROW>
else 
conditionalVec( simPSetIdx ) = 0;%#ok<AGROW>
end 
end 
if any( conditionalVec == 0 )
passFailValidation = 0;
else 
passFailValidation = 1;
end 
end 

function passFailValidation = ParallelGroupingToSeriesGroupingValidation( obj, val )
for simPSetIdx = 1:length( obj.SeriesGrouping )
if val( simPSetIdx ) == obj.ParallelAssembly.NumParallelCells && obj.SeriesGrouping( simPSetIdx ) == 1
conditionalVec( simPSetIdx ) = 1;%#ok<AGROW>
elseif val( simPSetIdx ) == 1
conditionalVec( simPSetIdx ) = 1;%#ok<AGROW>
else 
conditionalVec( simPSetIdx ) = 0;%#ok<AGROW>
end 
end 
if any( conditionalVec == 0 )
passFailValidation = 0;
else 
passFailValidation = 1;
end 
end 
end 


methods ( Static, Hidden )

function val = getRectangularPrismDimensions( Extent, Position )
faces = [ "top", "bottom", "left", "right", "back", "front" ];
rectangularPrismDefinition.bottom.X = [ Position.X, Extent.X ];
rectangularPrismDefinition.bottom.Y = [ Position.Y, Extent.Y ];
rectangularPrismDefinition.bottom.Z = repmat( Position.Z, 2, 2 );

rectangularPrismDefinition.top.X = [ Position.X, Extent.X ];
rectangularPrismDefinition.top.Y = [ Position.Y, Extent.Y ];
rectangularPrismDefinition.top.Z = repmat( Extent.Z, 2, 2 );

rectangularPrismDefinition.back.X = [ Position.X, Extent.X ];
rectangularPrismDefinition.back.Y = [ Position.Y, Position.Y ];
rectangularPrismDefinition.back.Z = [ [ Position.Z, Position.Z ]; ...
[ Extent.Z, Extent.Z ] ];

rectangularPrismDefinition.front.X = [ Position.X, Extent.X ];
rectangularPrismDefinition.front.Y = [ Extent.Y, Extent.Y ];
rectangularPrismDefinition.front.Z = [ [ Extent.Z, Extent.Z ]; ...
[ Position.Z, Position.Z ] ];

rectangularPrismDefinition.left.X = [ Position.X, Position.X ];
rectangularPrismDefinition.left.Y = [ Extent.Y, Extent.Y ];
rectangularPrismDefinition.left.Z = [ [ Position.Z, Extent.Z ]; ...
[ Position.Z, Extent.Z ] ];

rectangularPrismDefinition.right.X = [ Extent.X, Extent.X ];
rectangularPrismDefinition.right.Y = [ Extent.Y, Extent.Y ];
rectangularPrismDefinition.right.Z = [ [ Extent.Z, Position.Z ]; ...
[ Extent.Z, Position.Z ] ];

for faceIdx = 1:length( faces )
thesePoints.X = rectangularPrismDefinition.( faces{ faceIdx } ).X;
thesePoints.Y = rectangularPrismDefinition.( faces{ faceIdx } ).Y;
thesePoints.Z = rectangularPrismDefinition.( faces{ faceIdx } ).Z;
cdata = ones( size( thesePoints.Z ) );
if faceIdx == 1
[ X, Y, Z, C ] = deal( [  ], [  ], [  ], [  ] );
end 
X = [ X;thesePoints.X';NaN ];%#ok<AGROW>
Y = [ Y;thesePoints.Y';NaN ];%#ok<AGROW>
Z = [ Z;[ [ NaN( 2, faceIdx * 3 - 3 ) ], thesePoints.Z, [ NaN( 2, ( length( faces ) * 3 - ( 3 * faceIdx - 1 ) ) ) ] ];NaN( 1, length( faces ) * 3 ) ];%#ok<AGROW>
C = [ C;[ [ NaN( 2, faceIdx * 3 - 3 ) ], cdata, [ NaN( 2, ( length( faces ) * 3 - ( 3 * faceIdx - 1 ) ) ) ] ];NaN( 1, length( faces ) * 3 ) ];%#ok<AGROW>
end 
val = surf2patch( X, Y, Z, C );
end 

function endColumnLayout = remainderCellLocFcn( obj, MissingNoCells, endColumnLayout )
NoEvenPositions = sum( ~rem( 1:obj.ParallelAssembly.Rows, 2 ) );
NoOddPositions = obj.ParallelAssembly.Rows - NoEvenPositions;
RemainderCellPositions = obj.ParallelAssembly.RemainderCellPositions;
switch RemainderCellPositions
case "Odd"
if NoOddPositions > MissingNoCells
for rowIdx = 1:obj.ParallelAssembly.Rows
if mod( rowIdx, 2 ) ~= 0
else 
endColumnLayout( rowIdx ) = NaN;
end 
end 
else 
end 
[ ~, idx, ~ ] = unique( endColumnLayout, "stable" );
endColumnLayout( setdiff( 1:numel( endColumnLayout ), idx ) ) = NaN;
endColumnLayout( isnan( endColumnLayout ) ) = 0;
case "Even"
if NoEvenPositions > MissingNoCells
for i = 1:obj.ParallelAssembly.Rows
if mod( i, 2 ) == 0
else 
endColumnLayout( i ) = NaN;
end 
end 
else 
end 
[ ~, idx, ~ ] = unique( endColumnLayout, "stable" );
endColumnLayout( setdiff( 1:numel( endColumnLayout ), idx ) ) = NaN;
endColumnLayout( isnan( endColumnLayout ) ) = 0;
end 
end 

function InterParallelAssemblyGapArray = InterParallelAssemblyGapFcn( obj )



P = obj.ParallelAssembly.NumParallelCells;
Layout = obj.Layout;
S = obj.NumSeriesAssemblies;
InterParallelAssemblyGap = value( obj.InterParallelAssemblyGap, "m" );
InterParallelAssemblyGapArray = zeros( size( Layout ) );
ParallelAssemblyfactor = 0;
for seriesIdx = 1:S
InterParallelAssemblyGapArray( obj.Layout > ( seriesIdx - 1 ) * P & Layout <= seriesIdx * P & Layout ~= 0 ) = InterParallelAssemblyGap * ParallelAssemblyfactor;
ParallelAssemblyfactor = ParallelAssemblyfactor + 1;
end 
end 
end 

methods ( Access = protected )
function propgrp = getPropertyGroups( ~ )
propList = [ "NumSeriesAssemblies", "ParallelAssembly",  ...
"ModelResolution", "SeriesGrouping", "ParallelGrouping" ];
propgrp = matlab.mixin.util.PropertyGroup( propList );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpwo_qbs.p.
% Please follow local copyright laws when handling this file.

