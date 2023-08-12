classdef ( Sealed )ModuleAssembly < simscape.battery.builder.internal.Battery























































































properties ( Dependent )



Module simscape.battery.builder.Module



InterModuleGap( 1, 1 ){ mustBeA( InterModuleGap, [ "simscape.Value", "double" ] ) }


BalancingStrategy( 1, 1 )string{ mustBeMember( BalancingStrategy,  ...
[ "Passive", "" ] ) }



AmbientThermalPath( 1, 1 )string{ mustBeMember( AmbientThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) }






CoolantThermalPath( 1, 1 )string{ mustBeMember( CoolantThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) }



StackingAxis( 1, 1 )string{ mustBeMember( StackingAxis,  ...
[ "X", "Y" ] ) }


NumLevels( 1, 1 )double{ mustBeInteger,  ...
mustBePositive( NumLevels ), mustBeFinite }




MassFactor( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( MassFactor, 1 ) }



Position( 1, 3 )double{ mustBeReal, mustBeFinite }

Name( 1, 1 )string


CircuitConnection( 1, 1 )string{ mustBeMember( CircuitConnection,  ...
{ 'Series', 'Parallel', 'Grouped' } ) }



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

properties ( SetAccess = private, Hidden )

InterModuleGapInternal( 1, 1 ){ mustBeA( InterModuleGapInternal, { 'simscape.Value' } ),  ...
simscape.mustBeCommensurateUnit( InterModuleGapInternal, 'm' ) } = simscape.Value( 1 / 1000, 'm' )


ModulePositions( :, 1 )


Layout

PositionInternal simscape.battery.builder.internal.Position

NameInternal( 1, 1 )string

StackingAxisInternal( 1, 1 )string{ mustBeMember( StackingAxisInternal,  ...
[ "X", "Y" ] ) } = "Y"


CircuitConnectionInternal( 1, 1 )string ...
{ mustBeMember( CircuitConnectionInternal, [ "Series", "Parallel" ] ) } = 'Series'

BatteryPatchDefinition( :, 1 )

SimulationStrategyPatchDefinition( :, 1 )




MassFactorInternal( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( MassFactorInternal, 1 ) } = 1



NumLevelsInternal( 1, 1 )double{ mustBeInteger,  ...
mustBePositive( NumLevelsInternal ), mustBeFinite } = 1

ModuleOriginalPositions



NonCellResistanceInternal( 1, 1 )string{ mustBeMember( NonCellResistanceInternal,  ...
[ "Yes", "No" ] ) } = "No"
BlockTypeInternal



BalancingStrategyInternal( 1, 1 )string{ mustBeMember( BalancingStrategyInternal,  ...
[ "Passive", "" ] ) }



AmbientThermalPathInternal( 1, 1 )string{ mustBeMember( AmbientThermalPathInternal,  ...
[ "CellBasedThermalResistance", "" ] ) }






CoolantThermalPathInternal( 1, 1 )string{ mustBeMember( CoolantThermalPathInternal,  ...
[ "CellBasedThermalResistance", "" ] ) }
end 

properties ( SetAccess = private )


CellNumbering



ThermalNodes
end 

properties ( Dependent, SetAccess = protected, Hidden )


SimulationToHardwareMapping( :, : )uint16{ mustBeInteger }


TotNumModules( 1, 1 )double{ mustBeInteger }


UniqueComponents


UniqueNames
end 

properties ( Constant )

Type = 'ModuleAssembly'
end 

properties ( Dependent, Hidden )
BlockType( :, 1 )string
end 

properties ( Hidden )


ModuleInternal simscape.battery.builder.Module
end 

methods 

function obj = ModuleAssembly( namedArgs )
R36
namedArgs.Module simscape.battery.builder.Module = simscape.battery.builder.Module(  )
namedArgs.CircuitConnection( :, 1 )string{ mustBeMember( namedArgs.CircuitConnection,  ...
{ 'Series', 'Parallel', 'Grouped' } ) } = 'Series'
namedArgs.InterModuleGap( 1, 1 ){ mustBeA( namedArgs.InterModuleGap, [ "simscape.Value", "double" ] ) } = simscape.Value( 1 / 1000, 'm' )
namedArgs.BalancingStrategy( 1, 1 )string{ mustBeMember( namedArgs.BalancingStrategy,  ...
[ "Passive", "" ] ) } = ""
namedArgs.AmbientThermalPath( 1, 1 )string{ mustBeMember( namedArgs.AmbientThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) } = ""
namedArgs.CoolantThermalPath( 1, 1 )string{ mustBeMember( namedArgs.CoolantThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) } = ""
namedArgs.StackingAxis( 1, 1 )string{ mustBeMember( namedArgs.StackingAxis,  ...
[ "X", "Y" ] ) } = "Y"
namedArgs.Position( 1, 3 )double{ mustBeReal, mustBeFinite } = [ 0, 0, 0 ]
namedArgs.CoolingPlate( 1, 1 )string{ mustBeMember( namedArgs.CoolingPlate,  ...
[ "Top", "Bottom", "" ] ) } = ""
namedArgs.NumLevels( 1, 1 )double{ mustBeInteger,  ...
mustBePositive( namedArgs.NumLevels ), mustBeFinite } = 1
namedArgs.SharedCoolingPlate( 1, 1 )string{ mustBeMember( namedArgs.SharedCoolingPlate,  ...
[ "Yes", "No" ] ) } = "No"
namedArgs.MassFactor( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( namedArgs.MassFactor, 1 ) } = 1
namedArgs.Name( 1, 1 )string = "ModuleAssembly1"
namedArgs.NonCellResistance( 1, 1 )string = "No"
end 

if ~pmsl_checklicense( 'simscape_battery' )
error( message( 'physmod:battery:license:MissingLicense' ) );
end 
obj.Position = namedArgs.Position;
obj.StackingAxis = namedArgs.StackingAxis;
obj.Module = namedArgs.Module;
obj.CircuitConnection = namedArgs.CircuitConnection;

obj.InterModuleGap = namedArgs.InterModuleGap;
obj.NumLevels = namedArgs.NumLevels;
obj.MassFactor = namedArgs.MassFactor;

obj.Name = namedArgs.Name;
obj.BlockType = "ModuleAssemblyType1";
obj.BalancingStrategy = namedArgs.BalancingStrategy;
obj.AmbientThermalPath = namedArgs.AmbientThermalPath;
obj.CoolantThermalPath = namedArgs.CoolantThermalPath;
obj.NonCellResistance = namedArgs.NonCellResistance;
end 

function obj = set.Module( obj, val )
try 
assert( ~isequal( val, simscape.battery.builder.Module.empty(  ) ),  ...
message( "physmod:battery:builder:batteryclasses:EmptyModuleProperty" ) );
catch me
throwAsCaller( me )
end 
if ~isempty( obj.Module )
allModules = [ val( : ) ];
if all( [ allModules.BalancingStrategy ] == obj.BalancingStrategy )
else 
try 
assert( ~any( [ allModules.BalancingStrategy ] ~= "" ) && strcmp( obj.BalancingStrategy, "" ),  ...
message( "physmod:battery:builder:batteryclasses:BalancingStrategyMismatchWithModuleAssembly" ) );
catch me
throwAsCaller( me )
end 
end 
if all( [ allModules.AmbientThermalPath ] == obj.AmbientThermalPath )
else 
try 
assert( ~any( [ allModules.AmbientThermalPath ] ~= "" ) && strcmp( obj.AmbientThermalPath, "" ),  ...
message( "physmod:battery:builder:batteryclasses:AmbientThermalPathMismatchWithModuleAssembly" ) );
catch me
throwAsCaller( me )
end 
end 
if all( [ allModules.CoolantThermalPath ] == obj.CoolantThermalPath )
else 
try 
assert( ~any( [ allModules.CoolantThermalPath ] ~= "" ) && strcmp( obj.CoolantThermalPath, "" ),  ...
message( "physmod:battery:builder:batteryclasses:CoolantThermalPathMismatchWithModuleAssembly" ) );
catch me
throwAsCaller( me )
end 
end 
end 

if isempty( obj.ModuleInternal )
obj = updateModuleOriginalPositions( obj, val );
else 
if numel( val ) ~= numel( obj.ModuleOriginalPositions )
obj = updateModuleOriginalPositions( obj, val );
end 
end 
obj.ModuleInternal = val;
obj = updateBlockTypes( obj );
obj = obj.updateLayout;
end 

function value = get.Module( obj )
value = obj.ModuleInternal;
end 

function obj = set.InterModuleGap( obj, val )
if strcmp( class( val ), "double" )
warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueMeters" ) )
val = simscape.Value( val, "m" );
end 
simscape.mustBeCommensurateUnit( val, "m" )
try 
assert( value( val, "m" ) <= 10,  ...
message( "physmod:battery:builder:batteryclasses:HighInterModuleGap", "10" ) );
assert( value( val, "m" ) > 0,  ...
message( "physmod:battery:builder:batteryclasses:InvalidInterModuleGap" ) );
catch me
throwAsCaller( me )
end 
obj.InterModuleGapInternal = val;
obj = obj.updateLayout;
end 

function value = get.InterModuleGap( obj )
value = obj.InterModuleGapInternal;
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

function value = get.TotNumModules( obj )
value = length( obj.ModuleInternal( :, 1 ) ) * length( obj.ModuleInternal( 1, : ) );
try 
assert( value <= 50,  ...
message( "physmod:battery:builder:batteryclasses:InvalidNumModules", "50" ) );
catch me
throwAsCaller( me )
end 
end 

function obj = set.AmbientThermalPath( obj, val )
allParallelAssemblies = [ obj.ModuleInternal( : ).ParallelAssembly ];
allCells = [ allParallelAssemblies( : ).Cell ];
try 
assert( any( [ allCells.ThermalEffects ] ~= "omit" ) || strcmp( val, "" ),  ...
message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );
catch me
throwAsCaller( me )
end 

for moduleIdx = 1:obj.TotNumModules
obj.ModuleInternal( moduleIdx ).AmbientThermalPath = val;
end 
obj.AmbientThermalPathInternal = val;
end 

function value = get.AmbientThermalPath( obj )
value = obj.AmbientThermalPathInternal;
end 

function obj = set.CoolantThermalPath( obj, val )
allParallelAssemblies = [ obj.ModuleInternal( : ).ParallelAssembly ];
allCells = [ allParallelAssemblies( : ).Cell ];
try 
assert( any( [ allCells.ThermalEffects ] ~= "omit" ) || strcmp( val, "" ),  ...
message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );
catch me
throwAsCaller( me )
end 

for moduleIdx = 1:obj.TotNumModules
obj.ModuleInternal( moduleIdx ).CoolantThermalPath = val;
end 
obj.CoolantThermalPathInternal = val;
end 

function value = get.CoolantThermalPath( obj )
value = obj.CoolantThermalPathInternal;
end 

function obj = set.BalancingStrategy( obj, val )
for moduleIdx = 1:obj.TotNumModules
obj.ModuleInternal( moduleIdx ).BalancingStrategy = val;
end 
obj.BalancingStrategyInternal = val;
end 

function value = get.BalancingStrategy( obj )
value = obj.BalancingStrategyInternal;
end 

function obj = set.NumLevels( obj, val )
numOfModules = numel( obj.ModuleInternal( :, 1 ) ) * numel( obj.ModuleInternal( 1, : ) );
try 
assert( val <= numOfModules,  ...
message( "physmod:battery:builder:batteryclasses:InvalidNumLevels" ) );
catch me
throwAsCaller( me )
end 
obj.NumLevelsInternal = val;
obj = obj.updateLayout;
end 

function value = get.NumLevels( obj )
value = obj.NumLevelsInternal;
end 

function obj = set.Position( obj, val )
obj.PositionInternal = simscape.battery.builder.internal.Position( X = val( 1 ), Y = val( 2 ), Z = val( 3 ) );
obj = obj.updateLayout;
end 

function obj = set.CircuitConnection( obj, val )
obj.CircuitConnectionInternal = val;
end 

function value = get.CircuitConnection( obj )
value = obj.CircuitConnectionInternal;
end 

function value = get.UniqueComponents( obj )
moduleEquivalencyMatrix = ones( obj.TotNumModules, obj.TotNumModules );
parAssemblyEquivalencyMatrix = ones( obj.TotNumModules, obj.TotNumModules );
moduleNameEquivalencyMatrix = ones( obj.TotNumModules, obj.TotNumModules );
parAssemblyNameEquivalencyMatrix = ones( obj.TotNumModules, obj.TotNumModules );

ModuleKeyProperties = { 'NumSeriesAssemblies', 'ModelResolution', 'SeriesGrouping', 'ParallelGrouping',  ...
'InterParallelAssemblyGap', 'CoolingPlate', 'NonCellResistance' };

ParallelAssemblyKeyProperties = { 'NumParallelCells', 'Rows', 'Topology', 'ModelResolution',  ...
'InterCellGap', 'CoolingPlate', 'NonCellResistance' };

for moduleIdx = 1:obj.TotNumModules
if moduleIdx <= 10 && obj.TotNumModules > 10
startDigit = "0";
else 
startDigit = "";
end 
value( moduleIdx ).ModuleID = strcat( "Module", startDigit, string( moduleIdx ) );%#ok<AGROW>
value( moduleIdx ).ParallelAssemblyID = strcat( "ParallelAssembly", startDigit, string( moduleIdx ) );%#ok<AGROW>
if moduleIdx == obj.TotNumModules
moduleEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
parAssemblyEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
moduleNameEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
parAssemblyNameEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
if any( moduleEquivalencyMatrix( moduleIdx, : ) == 1 )
moduleEquivalencyMatrix( moduleIdx, end  ) = 1;
else 
moduleEquivalencyMatrix( moduleIdx, : ) = 0;
end 
if any( moduleNameEquivalencyMatrix( moduleIdx, : ) == 1 )
moduleNameEquivalencyMatrix( moduleIdx, end  ) = 1;
else 
moduleNameEquivalencyMatrix( moduleIdx, : ) = 0;
end 
if any( parAssemblyEquivalencyMatrix( moduleIdx, : ) == 1 )
parAssemblyEquivalencyMatrix( moduleIdx, end  ) = 1;
else 
parAssemblyEquivalencyMatrix( moduleIdx, : ) = 0;
end 
if any( parAssemblyNameEquivalencyMatrix( moduleIdx, : ) == 1 )
parAssemblyNameEquivalencyMatrix( moduleIdx, end  ) = 1;
else 
parAssemblyNameEquivalencyMatrix( moduleIdx, : ) = 0;
end 
else 
if moduleIdx == 1
else 
moduleEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
parAssemblyEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
moduleNameEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
parAssemblyNameEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
end 
for otherModuleIdx = ( moduleIdx + 1 ):obj.TotNumModules
if isequal( obj.ModuleInternal( moduleIdx ).Name, obj.ModuleInternal( otherModuleIdx ).Name )
moduleNameEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 1;
else 
moduleNameEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
end 
if isequal( obj.ModuleInternal( moduleIdx ).ParallelAssembly.Cell.Name, obj.ModuleInternal( otherModuleIdx ).ParallelAssembly.Cell.Name ) &&  ...
isequal( obj.ModuleInternal( moduleIdx ).ParallelAssembly.Cell.Format, obj.ModuleInternal( otherModuleIdx ).ParallelAssembly.Cell.Format ) &&  ...
isequal( obj.ModuleInternal( moduleIdx ).ParallelAssembly.Cell.Mass, obj.ModuleInternal( otherModuleIdx ).ParallelAssembly.Cell.Mass )
else 
moduleEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
parAssemblyEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
end 
for moduleFieldnamesIdx = 1:length( ModuleKeyProperties )
if isequal( obj.ModuleInternal( moduleIdx ).( ModuleKeyProperties{ moduleFieldnamesIdx } ), obj.ModuleInternal( otherModuleIdx ).( ModuleKeyProperties{ moduleFieldnamesIdx } ) )
else 
moduleEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
end 
end 
if isequal( obj.ModuleInternal( moduleIdx ).ParallelAssembly.Name, obj.ModuleInternal( otherModuleIdx ).ParallelAssembly.Name )
else 
parAssemblyNameEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
end 
for parAssemblyFieldnamesIdx = 1:length( ParallelAssemblyKeyProperties )
if isequal( obj.ModuleInternal( moduleIdx ).ParallelAssembly.( ParallelAssemblyKeyProperties{ parAssemblyFieldnamesIdx } ), obj.ModuleInternal( otherModuleIdx ).ParallelAssembly.( ParallelAssemblyKeyProperties{ parAssemblyFieldnamesIdx } ) )
else 
parAssemblyEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
end 
end 
end 
end 
end 
UniqueModuleBlockTypeIdx = 1;
UniqueParAssemblyBlockTypeIdx = 1;
UniqueModuleNameIdx = 1;
UniqueParAssemblyNameIdx = 1;
for rowIdx = 1:obj.TotNumModules
for columnIdx = 1:obj.TotNumModules
if moduleEquivalencyMatrix( rowIdx, columnIdx ) == 1
if rowIdx == obj.TotNumModules
moduleEquivalencyMatrix( ( end  ), columnIdx ) = 0;
else 
moduleEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
end 
value( columnIdx ).ModuleBlockType = strcat( "ModuleType", startDigit, string( UniqueModuleBlockTypeIdx ) );
else 
end 
if moduleNameEquivalencyMatrix( rowIdx, columnIdx ) == 1
if rowIdx == obj.TotNumModules
moduleNameEquivalencyMatrix( ( end  ), columnIdx ) = 0;
else 
moduleNameEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
end 
value( columnIdx ).ModuleUniqueName = obj.ModuleInternal( UniqueModuleNameIdx ).Name;
else 
end 
if parAssemblyNameEquivalencyMatrix( rowIdx, columnIdx ) == 1
if rowIdx == obj.TotNumModules
parAssemblyNameEquivalencyMatrix( ( end  ), columnIdx ) = 0;
else 
parAssemblyNameEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
end 
value( columnIdx ).ParallelAssemblyUniqueName = obj.ModuleInternal( UniqueParAssemblyNameIdx ).ParallelAssembly.Name;
else 
end 
if parAssemblyEquivalencyMatrix( rowIdx, columnIdx ) == 1
if rowIdx == obj.TotNumModules
parAssemblyEquivalencyMatrix( ( end  ), columnIdx ) = 0;
else 
parAssemblyEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
end 
value( columnIdx ).ParallelAssemblyBlockType = strcat( "ParallelAssemblyType", startDigit, string( UniqueParAssemblyBlockTypeIdx ) );
else 
end 
end 
if any( moduleEquivalencyMatrix( rowIdx, : ) == 1 )
UniqueModuleBlockTypeIdx = UniqueModuleBlockTypeIdx + 1;
else 
end 
if any( parAssemblyEquivalencyMatrix( rowIdx, : ) == 1 )
UniqueParAssemblyBlockTypeIdx = UniqueParAssemblyBlockTypeIdx + 1;
else 
end 
if any( moduleNameEquivalencyMatrix( rowIdx, : ) == 1 )
UniqueModuleNameIdx = UniqueModuleNameIdx + 1;
else 
end 
if any( parAssemblyNameEquivalencyMatrix( rowIdx, : ) == 1 )
UniqueParAssemblyNameIdx = UniqueParAssemblyNameIdx + 1;
else 
end 
end 
[ C_module, ia_module ] = unique( [ value.ModuleUniqueName ] );
[ C_pSet, ia_pSet ] = unique( [ value.ParallelAssemblyUniqueName ] );
[ value.ModuleUniqueName ] = deal( repmat( [  ], length( value ), 1 ) );
[ value.ParallelAssemblyUniqueName ] = deal( repmat( [  ], length( value ), 1 ) );
[ value( ia_module ).ModuleUniqueName ] = deal( C_module{ : } );
[ value( ia_pSet ).ParallelAssemblyUniqueName ] = deal( C_pSet{ : } );
end 


function value = get.BlockType( obj )
value = obj.BlockTypeInternal;
end 

function obj = set.BlockType( obj, val )
obj.BlockTypeInternal = val;
end 

function value = get.Position( obj )
value = [ obj.PositionInternal.X, obj.PositionInternal.Y, obj.PositionInternal.Z ];
end 

function obj = set.StackingAxis( obj, val )
obj.StackingAxisInternal = val;
obj = obj.updateLayout;
end 

function value = get.StackingAxis( obj )
value = obj.StackingAxisInternal;
end 

function obj = set.MassFactor( obj, val )
obj.MassFactorInternal = val;
end 

function value = get.MassFactor( obj )
value = obj.MassFactorInternal;
end 

function val = get.ThermalNodes( obj )
allParallelAssemblies = [ obj.ModuleInternal( : ).ParallelAssembly ];
if any( [ allParallelAssemblies.Topology ] == "" )
val.Locations = [  ];
val.Dimensions = [  ];
val.NumNodes = [  ];
else 

TotGroupedModelIdx = 1;
moduleAssemblyRows = length( obj.ModuleInternal( :, 1 ) );
moduleAssemblyColumns = length( obj.ModuleInternal( 1, : ) );
mdlAssembleLocations = [  ];
mdlAssembleDimensions = [  ];
for i = 1:moduleAssemblyRows
for j = 1:moduleAssemblyColumns
TotCellIdx = 1;
clear GroupedCellNodeDimensions GroupedCellNodeLocations CellNodeLocations CellNodeDimensions
GroupedCellNodeDimensions = zeros( length( obj.ModuleInternal( i, j ).SeriesGrouping ), 2 );
GroupedCellNodeLocations = zeros( length( obj.ModuleInternal( i, j ).SeriesGrouping ), 2 );
for parallelAssemblyIdx = 1:length( obj.ModuleInternal( i, j ).ParallelAssemblyRelativePositions )
for cellIdx = 1:length( obj.ModuleInternal( i, j ).ParallelAssemblyRelativePositions( parallelAssemblyIdx ).ParallelAssembly )
thisPosition = obj.ModuleInternal( i, j ).ParallelAssemblies( parallelAssemblyIdx ).CellCenterPositions( cellIdx );
thesePoints = [ obj.ModuleInternal( i, j ).ParallelAssemblies( parallelAssemblyIdx ).CellPoints( cellIdx ).Points ];
CellNodeLocations( TotCellIdx, : ) = abs( [ thisPosition.X, thisPosition.Y ] );%#ok<AGROW>
CellNodeDimensions( TotCellIdx, : ) = [ ( max( max( abs( thesePoints.XData ) ) ) - min( min( abs( thesePoints.XData ) ) ) ), ( max( max( abs( thesePoints.YData ) ) ) - min( min( abs( thesePoints.YData ) ) ) ) ];%#ok<AGROW>
TotCellIdx = TotCellIdx + 1;
end 
end 

if strcmp( obj.ModuleInternal( i, j ).ModelResolution, 'Detailed' )


GroupedCellNodeDimensions = CellNodeDimensions;
GroupedCellNodeLocations = CellNodeLocations;
elseif strcmp( obj.ModuleInternal( i, j ).ModelResolution, 'Grouped' )

Idx = 1;
InitialGroupedCellIdx = 1;
EndGroupedCellIdx = 0;
TotGroupedModelIdx = 1;
for z = 1:sum( obj.ModuleInternal( i, j ).ParallelGrouping )
EndGroupedCellIdx = obj.ModuleInternal( i, j ).SeriesGrouping( Idx ) * (  - obj.ModuleInternal( i, j ).ParallelGrouping( Idx ) + ( obj.ModuleInternal( i, j ).ParallelAssembly.NumParallelCells + 1 ) ) + EndGroupedCellIdx;
if obj.ModuleInternal( i, j ).StackingAxis == "X"
GroupedCellNodeDimensions( TotGroupedModelIdx, : ) = [ value( obj.ModuleInternal( i, j ).XExtent, "m" ) - obj.ModuleInternal( i, j ).Position( 1 ),  ...
( abs( value( obj.ModuleInternal( i, j ).YExtent, "m" ) ) - obj.ModuleInternal( i, j ).Position( 2 ) ) * obj.ModuleInternal( i, j ).SeriesGrouping( Idx ) / sum( obj.ModuleInternal( i, j ).SeriesGrouping ) ];
GroupedCellNodeLocations( TotGroupedModelIdx, : ) = [ mean( CellNodeLocations( InitialGroupedCellIdx:EndGroupedCellIdx, 1 ) ),  ...
mean( CellNodeLocations( InitialGroupedCellIdx:EndGroupedCellIdx, 2 ) ) ];
else 
GroupedCellNodeDimensions( TotGroupedModelIdx, : ) = [ ( abs( value( obj.ModuleInternal( i, j ).YExtent, "m" ) ) - obj.ModuleInternal( i, j ).Position( 2 ) ) * obj.ModuleInternal( i, j ).SeriesGrouping( Idx ) / sum( obj.ModuleInternal( i, j ).SeriesGrouping ),  ...
value( obj.ModuleInternal( i, j ).XExtent, "m" ) - obj.ModuleInternal( i, j ).Position( 1 ) ];
GroupedCellNodeLocations( TotGroupedModelIdx, : ) = [ mean( CellNodeLocations( InitialGroupedCellIdx:EndGroupedCellIdx, 1 ) ),  ...
mean( CellNodeLocations( InitialGroupedCellIdx:EndGroupedCellIdx, 2 ) ) ];
end 
TotGroupedModelIdx = TotGroupedModelIdx + 1;
InitialGroupedCellIdx = EndGroupedCellIdx + 1;
if obj.ModuleInternal( i, j ).ParallelGrouping( Idx ) == 1
Idx = Idx + 1;
else 
end 
end 
elseif strcmp( obj.ModuleInternal( i, j ).ModelResolution, 'Lumped' )
GroupedCellNodeDimensions( TotGroupedModelIdx, : ) = [ abs( value( obj.XExtent, "m" ) - obj.PositionInternal.X ),  ...
abs( value( obj.YExtent, "m" ) - obj.PositionInternal.Y ) ];
GroupedCellNodeLocations( TotGroupedModelIdx, : ) = [ mean( CellNodeLocations( :, 1 ) ),  ...
mean( CellNodeLocations( :, 2 ) ) ];
end 
mdlAssembleLocations = [ mdlAssembleLocations;GroupedCellNodeLocations ];%#ok<AGROW>
mdlAssembleDimensions = [ mdlAssembleDimensions;GroupedCellNodeDimensions ];%#ok<AGROW>
end 
end 
val.Locations = mdlAssembleLocations;
val.Dimensions = mdlAssembleDimensions;
val.NumNodes = length( mdlAssembleLocations( :, 1 ) );
end 
end 

function val = get.PackagingVolume( obj )
allParallelAssemblies = [ obj.ModuleInternal( : ).ParallelAssembly ];
if any( [ allParallelAssemblies.Topology ] == "" )
val = simscape.Value( [  ], "m^3" );
else 
moduleAssemblyRows = length( obj.ModuleInternal( :, 1 ) );
moduleAssemblyColumns = length( obj.ModuleInternal( 1, : ) );
modAssemblyVolume = simscape.Value( 0, "m^3" );
for rowsIdx = 1:moduleAssemblyRows
for colIdx = 1:moduleAssemblyColumns
modAssemblyVolume = modAssemblyVolume + obj.ModuleInternal( rowsIdx, colIdx ).PackagingVolume;
end 
end 
val = modAssemblyVolume;
end 
end 

function value = get.CumulativeMass( obj )
moduleAssemblyWeight = simscape.Value( 0, "kg" );
moduleAssemblyRows = length( obj.ModuleInternal( :, 1 ) );
moduleAssemblyColumns = length( obj.ModuleInternal( 1, : ) );
for rowsIdx = 1:moduleAssemblyRows
for colIdx = 1:moduleAssemblyColumns
moduleAssemblyWeight = moduleAssemblyWeight + obj.ModuleInternal( rowsIdx, colIdx ).CumulativeMass;
end 
end 
value = moduleAssemblyWeight * obj.MassFactor;
end 

function value = get.SimulationToHardwareMapping( obj )
BatteryTypes = [ "ModuleAssembly", "Module", "ParallelAssembly", "Cell", "Model" ];
CellIndex = [  ];
ParallelAssemblyIndex = [  ];
ModuleIndex = [  ];
ModelIndex = [  ];
numModules = length( obj.ModuleInternal( :, 1 ) ) * length( obj.ModuleInternal( 1, : ) );
for moduleIdx = 1:numModules
ModuleIndex = [ ModuleIndex;moduleIdx * ones( length( obj.Module( moduleIdx ).SimulationToHardwareMapping.Module ), 1 ) ];%#ok<AGROW>
ParallelAssemblyIndex = [ ParallelAssemblyIndex;obj.Module( moduleIdx ).SimulationToHardwareMapping.ParallelAssembly ];%#ok<AGROW>
CellIndex = [ CellIndex;obj.Module( moduleIdx ).SimulationToHardwareMapping.Cell ];%#ok<AGROW>
if moduleIdx == 1
ModelIndex = [ ModelIndex;obj.Module( moduleIdx ).SimulationToHardwareMapping.Model ];%#ok<AGROW>
else 
ModelIndex = [ ModelIndex;obj.Module( moduleIdx ).SimulationToHardwareMapping.Model + ModelIndex( end  ) ];%#ok<AGROW>
end 
end 
SimulationToHardware( :, 1 ) = ones( length( ModuleIndex ), 1 );
SimulationToHardware( :, 2 ) = ModuleIndex;
SimulationToHardware( :, 3 ) = ParallelAssemblyIndex;
SimulationToHardware( :, 4 ) = CellIndex;
SimulationToHardware( :, 5 ) = ModelIndex;
value = array2table( SimulationToHardware );
value.Properties.VariableNames = BatteryTypes;
end 

function value = get.NumModels( obj )
value = obj.SimulationToHardwareMapping.Model( end  );
end 

end 

methods ( Hidden )

function obj = updateBlockTypes( obj )
uniqueComponents = obj.UniqueComponents;
for moduleIdx = 1:length( [ uniqueComponents.ModuleID ] )
obj.ModuleInternal( moduleIdx ).BlockType = uniqueComponents( moduleIdx ).ModuleBlockType;
obj.ModuleInternal( moduleIdx ).ParallelAssembly.BlockType = uniqueComponents( moduleIdx ).ParallelAssemblyBlockType;
if isempty( uniqueComponents( moduleIdx ).ModuleUniqueName )
obj.ModuleInternal( moduleIdx ).Name = uniqueComponents( moduleIdx ).ModuleID;
else 
obj.ModuleInternal( moduleIdx ).Name = uniqueComponents( moduleIdx ).ModuleUniqueName;
end 
if isempty( uniqueComponents( moduleIdx ).ParallelAssemblyUniqueName )
obj.ModuleInternal( moduleIdx ).ParallelAssembly.Name = uniqueComponents( moduleIdx ).ParallelAssemblyID;
else 
obj.ModuleInternal( moduleIdx ).ParallelAssembly.Name = uniqueComponents( moduleIdx ).ParallelAssemblyUniqueName;
end 
end 
end 

function obj = updatePoints( obj )
allParallelAssemblies = [ obj.ModuleInternal( : ).ParallelAssembly ];
if any( [ allParallelAssemblies.Topology ] == "" )
obj.BatteryPatchDefinition.faces = NaN;
obj.BatteryPatchDefinition.vertices = NaN( 1, 2 );
obj.BatteryPatchDefinition.facevertexcdata = NaN;
obj.SimulationStrategyPatchDefinition = obj.BatteryPatchDefinition;
else 
moduleAssemblyRows = length( obj.ModuleInternal( :, 1 ) );
moduleAssemblyColumns = length( obj.ModuleInternal( 1, : ) );
moduleAssemblyPatch = struct( "faces", double.empty( 0, 4 ), "vertices", double.empty( 0, 3 ), "facevertexcdata", double.empty( 0, 1 ) );
moduleAssemblySimPatch = struct( "faces", double.empty( 0, 4 ), "vertices", double.empty( 0, 3 ), "facevertexcdata", double.empty( 0, 1 ) );
for rowsIdx = 1:moduleAssemblyRows
for colIdx = 1:moduleAssemblyColumns
if moduleAssemblyColumns > 1
if colIdx == 1
maxFaceValue = 0;
maxSimFaceValue = 0;
else 
maxFaceValue = max( moduleAssemblyPatch.faces( : ) );
maxSimFaceValue = max( moduleAssemblySimPatch.faces( : ) );
end 
moduleAssemblyPatch.faces = [ moduleAssemblyPatch.faces;obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.faces + maxFaceValue ];
moduleAssemblyPatch.vertices = [ moduleAssemblyPatch.vertices;obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.vertices ];
moduleAssemblyPatch.facevertexcdata = [ moduleAssemblyPatch.facevertexcdata;obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.facevertexcdata ];

moduleAssemblySimPatch.faces = [ moduleAssemblySimPatch.faces;obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.faces + maxSimFaceValue ];
moduleAssemblySimPatch.vertices = [ moduleAssemblySimPatch.vertices;obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.vertices ];
moduleAssemblySimPatch.facevertexcdata = [ moduleAssemblySimPatch.facevertexcdata;obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.facevertexcdata ];

elseif moduleAssemblyColumns == 1 && moduleAssemblyRows == 1
moduleAssemblyPatch.faces = [ obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.faces ];
moduleAssemblyPatch.vertices = [ obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.vertices ];
moduleAssemblyPatch.facevertexcdata = [ obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.facevertexcdata ];

moduleAssemblySimPatch.faces = [ obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.faces ];
moduleAssemblySimPatch.vertices = [ obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.vertices ];
moduleAssemblySimPatch.facevertexcdata = [ obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.facevertexcdata ];
else 
end 
end 
if moduleAssemblyRows > 1
if rowsIdx == 1
maxFaceValue = 0;
maxSimFaceValue = 0;
else 
maxFaceValue = max( moduleAssemblyPatch.faces( : ) );
maxSimFaceValue = max( moduleAssemblySimPatch.faces( : ) );
end 
moduleAssemblyPatch.faces = [ moduleAssemblyPatch.faces;obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.faces + maxFaceValue ];
moduleAssemblyPatch.vertices = [ moduleAssemblyPatch.vertices;obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.vertices ];
moduleAssemblyPatch.facevertexcdata = [ moduleAssemblyPatch.facevertexcdata;obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.facevertexcdata ];

moduleAssemblySimPatch.faces = [ moduleAssemblySimPatch.faces;obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.faces + maxSimFaceValue ];
moduleAssemblySimPatch.vertices = [ moduleAssemblySimPatch.vertices;obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.vertices ];
moduleAssemblySimPatch.facevertexcdata = [ moduleAssemblySimPatch.facevertexcdata;obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.facevertexcdata ];

elseif moduleAssemblyColumns == 1 && moduleAssemblyRows == 1
moduleAssemblyPatch.faces = [ obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.faces ];
moduleAssemblyPatch.vertices = [ obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.vertices ];
moduleAssemblyPatch.facevertexcdata = [ obj.ModuleInternal( rowsIdx, colIdx ).BatteryPatchDefinition.facevertexcdata ];

moduleAssemblySimPatch.faces = [ obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.faces ];
moduleAssemblySimPatch.vertices = [ obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.vertices ];
moduleAssemblySimPatch.facevertexcdata = [ obj.ModuleInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.facevertexcdata ];
else 
end 
end 
obj.BatteryPatchDefinition = moduleAssemblyPatch;
obj.SimulationStrategyPatchDefinition = moduleAssemblySimPatch;
end 
end 

function value = getExtent( obj, axisExtentName )
allParallelAssemblies = [ obj.ModuleInternal( : ).ParallelAssembly ];
if any( [ allParallelAssemblies.Topology ] == "" )
value = simscape.Value( [  ], "m" );
else 
moduleAssemblyRows = length( obj.ModuleInternal( :, 1 ) );
moduleAssemblyColumns = length( obj.ModuleInternal( 1, : ) );
moduleExtent = ones( length( obj.ModuleInternal( :, 1 ) ), length( obj.ModuleInternal( 1, : ) ) );
for rowsIdx = 1:moduleAssemblyRows
for columnsIdx = 1:moduleAssemblyColumns
parallelAssemblyExtent = zeros( obj.Module( rowsIdx, columnsIdx ).NumSeriesAssemblies, 1 );
for parallelAssemblyIdx = 1:length( parallelAssemblyExtent )
allPoints = [ obj.ModuleInternal( rowsIdx, columnsIdx ).ParallelAssemblies( parallelAssemblyIdx ).CellPoints.Points ];
if strcmp( axisExtentName, "YData" )
parallelAssemblyExtent( parallelAssemblyIdx ) = min( min( ( [ allPoints.( axisExtentName ) ] ) ) );
else 
parallelAssemblyExtent( parallelAssemblyIdx ) = max( max( abs( [ allPoints.( axisExtentName ) ] ) ) );
end 
end 
if strcmp( axisExtentName, "YData" )
moduleExtent( rowsIdx, columnsIdx ) = min( parallelAssemblyExtent );
else 
moduleExtent( rowsIdx, columnsIdx ) = max( parallelAssemblyExtent );
end 
end 
end 
if strcmp( axisExtentName, "YData" )
value = simscape.Value( min( moduleExtent ), "m" );
else 
value = simscape.Value( max( moduleExtent ), "m" );
end 
end 
end 

end 

methods ( Access = private )

function obj = updateLayout( obj )
if ~isempty( obj.ModuleInternal )
try 
assert( ~all( size( obj.ModuleInternal ) > 1 ),  ...
message( "physmod:battery:builder:batteryclasses:ModuleMatrix" ) );
catch me
throwAsCaller( me )
end 
numOfModules = numel( obj.ModuleInternal( :, 1 ) ) * numel( obj.ModuleInternal( 1, : ) );
if strcmp( obj.StackingAxis, "Y" )
obj.Layout = reshape( 1:numOfModules, 1, numOfModules );
elseif strcmp( obj.StackingAxis, "X" )
obj.Layout = reshape( 1:numOfModules, numOfModules, 1 );
end 
obj = obj.updateModulePositions;
obj = obj.updatePoints;
obj = obj.updateCellNumbering;
end 
end 

function obj = updateModuleOriginalPositions( obj, val )
numOfModules = numel( val( :, 1 ) ) * numel( val( 1, : ) );
for moduleIdx = 1:numOfModules
obj.ModuleOriginalPositions( moduleIdx ).Position = val( moduleIdx ).PositionInternal;
end 
end 

function obj = updateCellNumbering( obj )
obj.CellNumbering = [  ];
if isempty( obj.ModuleInternal )
else 
if isempty( obj.ModuleInternal( 1, 1 ).CellNumbering )
else 
moduleAssemblyRows = length( obj.ModuleInternal( :, 1 ) );
moduleAssemblyColumns = length( obj.ModuleInternal( 1, : ) );
moduleIdx = 1;
for moduleAssemblyRowsIdx = 1:moduleAssemblyRows
for moduleAssemblyColIdx = 1:moduleAssemblyColumns
obj.CellNumbering( moduleIdx ).Module = moduleIdx;
for parallelAssemblyIdx = 1:obj.ModuleInternal( moduleAssemblyRowsIdx, moduleAssemblyColIdx ).NumSeriesAssemblies
obj.CellNumbering( moduleIdx ).ModuleNumbering( parallelAssemblyIdx ).ParallelAssembly = obj.ModuleInternal( moduleAssemblyRowsIdx, moduleAssemblyColIdx ).CellNumbering( parallelAssemblyIdx ).ParallelAssembly;
obj.CellNumbering( moduleIdx ).ModuleNumbering( parallelAssemblyIdx ).Cells = obj.ModuleInternal( moduleAssemblyRowsIdx, moduleAssemblyColIdx ).CellNumbering( parallelAssemblyIdx ).Cells;
end 
moduleIdx = moduleIdx + 1;
end 
end 
end 
end 
end 

function obj = updateModulePositions( obj )
allParallelAssemblies = [ obj.ModuleInternal( : ).ParallelAssembly ];
if any( [ allParallelAssemblies.Topology ] == "" )
else 
NumOfModules = length( obj.ModuleInternal( :, 1 ) ) * length( obj.ModuleInternal( 1, : ) );

positionIndicatorZaxis = NumOfModules / obj.NumLevels;
positionIndicatorZaxisFactor = 1;
if isempty( obj.PositionInternal )
[ moduleAssemblyPosition.X, moduleAssemblyPosition.Y, moduleAssemblyPosition.Z ] = deal( 0, 0, 0 );
else 
moduleAssemblyPosition = obj.PositionInternal;
end 

[ prevModuleExtend.X, prevModuleExtend.Y, prevModuleExtend.Z ] = deal( moduleAssemblyPosition.X, moduleAssemblyPosition.Y, moduleAssemblyPosition.Z );
ModuleGap = value( convert( obj.InterModuleGap, 'm' ) );
for moduleIdx = 1:NumOfModules
gapFactor = double( moduleIdx > 1 );
if strcmp( obj.StackingAxis, "Y" )
if abs( obj.ModuleOriginalPositions( moduleIdx ).Position.X ) > 0
thisX = obj.ModuleOriginalPositions( moduleIdx ).Position.X + moduleAssemblyPosition.X;
else 
thisX = moduleAssemblyPosition.X;
end 
thisY =  - ( ModuleGap * gapFactor ) + prevModuleExtend.Y;


if moduleIdx > ceil( positionIndicatorZaxis * positionIndicatorZaxisFactor )
thisY = moduleAssemblyPosition.Y;
thisZ = ( ModuleGap + prevModuleExtend.Z );
positionIndicatorZaxisFactor = 1 + positionIndicatorZaxisFactor;
elseif positionIndicatorZaxisFactor > 1
thisZ = thisZ;%#ok<ASGSL>
else 
thisZ = moduleAssemblyPosition.Z;
end 
elseif strcmp( obj.StackingAxis, "X" )
thisX = ModuleGap * gapFactor + prevModuleExtend.X;
if abs( obj.ModuleOriginalPositions( moduleIdx ).Position.Y ) > 0
thisY = obj.ModuleOriginalPositions( moduleIdx ).Position.Y + moduleAssemblyPosition.Y;
else 
thisY = moduleAssemblyPosition.Y;
end 
if moduleIdx > ceil( positionIndicatorZaxis * positionIndicatorZaxisFactor )
thisX = moduleAssemblyPosition.X;
thisZ = ( ModuleGap + prevModuleExtend.Z );
positionIndicatorZaxisFactor = 1 + positionIndicatorZaxisFactor;
elseif positionIndicatorZaxisFactor > 1
thisZ = thisZ;%#ok<ASGSL>
else 
thisZ = moduleAssemblyPosition.Z;
end 
end 
obj.ModuleInternal( moduleIdx ).Position = [ thisX, thisY, thisZ ];
prevModuleExtend.X = value( obj.ModuleInternal( moduleIdx ).XExtent, 'm' );
prevModuleExtend.Y = value( obj.ModuleInternal( moduleIdx ).YExtent, 'm' );
prevModuleExtend.Z = value( obj.ModuleInternal( moduleIdx ).ZExtent, 'm' );
end 
end 
end 
end 

methods ( Access = protected )
function propgrp = getPropertyGroups( ~ )
propList = "Module";
propgrp = matlab.mixin.util.PropertyGroup( propList );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpEFRfp0.p.
% Please follow local copyright laws when handling this file.

