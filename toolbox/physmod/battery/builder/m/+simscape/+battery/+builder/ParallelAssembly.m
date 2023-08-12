classdef ( Sealed )ParallelAssembly < simscape.battery.builder.internal.Battery





























































































































properties ( Dependent )





Cell( 1, 1 )simscape.battery.builder.Cell



NumParallelCells( 1, 1 )double{ mustBeInteger,  ...
mustBePositive( NumParallelCells ),  ...
mustBeLessThan( NumParallelCells, 150 ) }



Rows( 1, 1 )double{ mustBeInteger, mustBePositive( Rows ),  ...
mustBeLessThan( Rows, 50 ) }




Topology( 1, 1 )string{ mustBeMember( Topology,  ...
[ "Square", "Hexagonal", "SingleStack", "NStack", "Single", "" ] ) }







ModelResolution( :, 1 )string{ mustBeMember( ModelResolution,  ...
[ "Lumped", "Detailed" ] ) }


BalancingStrategy( 1, 1 )string{ mustBeMember( BalancingStrategy,  ...
[ "Passive", "" ] ) }



AmbientThermalPath( 1, 1 )string{ mustBeMember( AmbientThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) }






CoolantThermalPath( 1, 1 )string{ mustBeMember( CoolantThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) }



CoolingPlate( :, 1 )string{ mustBeMember( CoolingPlate,  ...
[ "Top", "Bottom", "" ] ) }



InterCellGap( 1, 1 ){ mustBeA( InterCellGap, [ "simscape.Value", "double" ] ) }



Position( 1, 3 )double{ mustBeReal, mustBeFinite }

Name( 1, 1 )string




MassFactor( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( MassFactor, 1 ) }



StackingAxis( 1, 1 )string{ mustBeMember( StackingAxis,  ...
[ "X", "Y" ] ) }



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
properties ( Dependent, SetAccess = protected, Hidden )


SimulationToHardwareMapping( :, : )uint16{ mustBeInteger }
end 

properties ( Access = private )





CellInternal( 1, 1 )simscape.battery.builder.Cell



NumParallelCellsInternal( 1, 1 )double{ mustBeInteger,  ...
mustBePositive( NumParallelCellsInternal ),  ...
mustBeLessThan( NumParallelCellsInternal, 200 ) } = 1



RowsInternal( 1, 1 )double{ mustBeInteger, mustBePositive( RowsInternal ),  ...
mustBeLessThan( RowsInternal, 50 ) } = 1







ModelResolutionInternal( :, 1 )string{ mustBeMember( ModelResolutionInternal,  ...
[ "Lumped", "Detailed" ] ) } = "Lumped"



BalancingStrategyInternal( 1, 1 )string{ mustBeMember( BalancingStrategyInternal,  ...
[ "Passive", "" ] ) }




AmbientThermalPathInternal( 1, 1 )string{ mustBeMember( AmbientThermalPathInternal,  ...
[ "CellBasedThermalResistance", "" ] ) }




CoolantThermalPathInternal( 1, 1 )string{ mustBeMember( CoolantThermalPathInternal,  ...
[ "CellBasedThermalResistance", "" ] ) }



CoolingPlateInternal( :, 1 )string{ mustBeMember( CoolingPlateInternal,  ...
[ "Top", "Bottom", "" ] ) }



InterCellGapInternal( 1, 1 ){ mustBeA( InterCellGapInternal, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( InterCellGapInternal, "m" ) } = simscape.Value( 0.001, "m" )

end 

properties ( SetAccess = private )


CellNumbering



ThermalNodes
end 

properties ( SetAccess = private, Hidden )


CellPositions( :, 1 )


CellCenterPositions( :, 1 )



CellRelativePositions( :, 1 )


CellPoints( :, 1 )


CellColors( :, 1 )simscape.battery.builder.internal.StateVariable


Layout

BatteryPatchDefinition( :, 1 )

RemainderCellPositions( :, 1 )string{ mustBeMember(  ...
RemainderCellPositions, [ "Odd", "Even" ] ) } = "Odd"




TopologyInternal( 1, 1 )string{ mustBeMember( TopologyInternal,  ...
[ "Square", "Hexagonal", "SingleStack", "NStack", "Single", "" ] ) }



StackingAxisInternal( 1, 1 )string{ mustBeMember( StackingAxisInternal,  ...
[ "X", "Y" ] ) } = "Y"

ThermalBoundaryConditions




MassFactorInternal( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( MassFactorInternal, 1 ) } = 1



PositionInternal simscape.battery.builder.internal.Position

NameInternal( 1, 1 )string



NonCellResistanceInternal( 1, 1 )string{ mustBeMember( NonCellResistanceInternal,  ...
[ "Yes", "No" ] ) } = "No"
BlockTypeInternal
end 

properties ( SetAccess = private, Dependent, Hidden )


Columns( 1, 1 )double{ mustBeInteger }

SimulationStrategyPatchDefinition( :, 1 )
end 

properties ( Constant )

Type = "ParallelAssembly"
end 

properties ( Dependent, Hidden )
BlockType
end 

methods 
function obj = ParallelAssembly( namedArgs )
R36
namedArgs.Cell( 1, 1 )simscape.battery.builder.Cell = simscape.battery.builder.Cell
namedArgs.NumParallelCells( 1, 1 )double{ mustBeInteger,  ...
mustBePositive( namedArgs.NumParallelCells ),  ...
mustBeLessThan( namedArgs.NumParallelCells, 150 ) } = 1
namedArgs.Rows( 1, 1 )double{ mustBeInteger, mustBePositive( namedArgs.Rows ),  ...
mustBeLessThan( namedArgs.Rows, 50 ) } = 1
namedArgs.Topology( 1, 1 )string{ mustBeMember( namedArgs.Topology,  ...
[ "Square", "Hexagonal", "SingleStack", "NStack", "Single", "" ] ) } = ""
namedArgs.ModelResolution( :, 1 )string{ mustBeMember( namedArgs.ModelResolution,  ...
[ "Lumped", "Detailed" ] ) } = "Lumped"
namedArgs.BalancingStrategy( 1, 1 )string{ mustBeMember( namedArgs.BalancingStrategy,  ...
[ "Passive", "" ] ) } = ""
namedArgs.AmbientThermalPath( 1, 1 )string{ mustBeMember( namedArgs.AmbientThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) } = ""
namedArgs.CoolantThermalPath( 1, 1 )string{ mustBeMember( namedArgs.CoolantThermalPath,  ...
[ "CellBasedThermalResistance", "" ] ) } = ""
namedArgs.CoolingPlate( :, 1 )string{ mustBeMember( namedArgs.CoolingPlate,  ...
[ "Top", "Bottom", "" ] ) } = ""
namedArgs.InterCellGap( 1, 1 ){ mustBeA( namedArgs.InterCellGap, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.001, "m" )
namedArgs.Position( 1, 3 )double{ mustBeReal, mustBeFinite } = [ 0, 0, 0 ]
namedArgs.MassFactor( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
mustBeGreaterThanOrEqual( namedArgs.MassFactor, 1 ) } = 1
namedArgs.StackingAxis( 1, 1 )string{ mustBeMember( namedArgs.StackingAxis,  ...
[ "X", "Y" ] ) } = "Y"
namedArgs.Name( 1, 1 )string = "ParallelAssembly1"
namedArgs.NonCellResistance( 1, 1 )string = "No"
end 

if ~pmsl_checklicense( 'simscape_battery' )
error( message( 'physmod:battery:license:MissingLicense' ) );
end 

obj = obj.updateCellColors;

obj.CellPositions = repmat( simscape.battery.builder.internal.Position, 1, 1 );
if isempty( namedArgs.Cell )
obj.Cell = simscape.battery.builder.Cell(  );
else 
obj.Cell = namedArgs.Cell;

obj.Cell.Position = [ 0, 0, 0 ];
end 
obj.AmbientThermalPath = namedArgs.AmbientThermalPath;
obj.CoolantThermalPath = namedArgs.CoolantThermalPath;
obj.CoolingPlate = namedArgs.CoolingPlate;
obj.InterCellGap = namedArgs.InterCellGap;
obj.ModelResolution = namedArgs.ModelResolution;
obj.BalancingStrategy = namedArgs.BalancingStrategy;
obj.StackingAxis = namedArgs.StackingAxis;
obj.MassFactor = namedArgs.MassFactor;
obj.NumParallelCells = namedArgs.NumParallelCells;
obj.Topology = namedArgs.Topology;
obj.Rows = namedArgs.Rows;
obj.Position = namedArgs.Position;
obj.Name = namedArgs.Name;
obj.BlockType = "ParallelAssemblyType1";
obj.NonCellResistance = namedArgs.NonCellResistance;
end 

function obj = set.NumParallelCells( obj, val )

obj.NumParallelCellsInternal = val;


obj = obj.updateLayout;
end 

function value = get.BlockType( obj )
value = obj.BlockTypeInternal;
end 

function obj = set.BlockType( obj, val )
obj.BlockTypeInternal = val;
end 

function value = get.NumParallelCells( obj )
value = obj.NumParallelCellsInternal;
end 

function obj = set.Rows( obj, val )
if isempty( obj.Topology )
else 
try 
assert( ( ( obj.Topology ~= "SingleStack" ) || ( val <= 1 ) ),  ...
message( "physmod:battery:builder:batteryclasses:RowsTopologyMismatch" ) );
catch me
throwAsCaller( me )
end 
end 
try 
assert( ( val <= obj.NumParallelCells ),  ...
message( "physmod:battery:builder:batteryclasses:RowsNumParallelCellsMismatch" ) );
catch me
throwAsCaller( me )
end 
obj.RowsInternal = val;

obj = obj.updateLayout;
end 

function value = get.Rows( obj )
value = obj.RowsInternal;
end 

function obj = set.Position( obj, val )
obj.PositionInternal = simscape.battery.builder.internal.Position( X = val( 1 ), Y = val( 2 ), Z = val( 3 ) );

obj = obj.updateLayout;
end 

function value = get.Position( obj )
value = [ obj.PositionInternal.X, obj.PositionInternal.Y, obj.PositionInternal.Z ];
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

function obj = set.Cell( obj, val )
try 
assert( ~isequal( val, simscape.battery.builder.Cell.empty(  ) ),  ...
message( "physmod:battery:builder:batteryclasses:EmptyCellProperty" ) );
catch me
throwAsCaller( me )
end 


if isempty( obj.Topology )
else 
try 
assert( ( ( val.Format ~= "Pouch" ) && ( val.Format ~= "Prismatic" ) ) || ( ( obj.Topology ~= "Hexagonal" ) && ( obj.Topology ~= "Square" ) ),  ...
message( "physmod:battery:builder:batteryclasses:CellFormatTopologyMismatch" ) );

assert( ( ( val.Format ~= "Cylindrical" ) ) || ( ( obj.Topology ~= "SingleStack" ) && ( obj.Topology ~= "NStack" ) ),  ...
message( "physmod:battery:builder:batteryclasses:CellFormatTopologyMismatch" ) );
catch me
throwAsCaller( me )
end 
end 

if strcmp( obj.ThermalBoundaryConditions.Top, "Adiabatic" ) && strcmp( obj.ThermalBoundaryConditions.Bottom, "Adiabatic" ) &&  ...
strcmp( obj.ThermalBoundaryConditions.Ambient, "Adiabatic" )
else 
try 
assert( ( val.ThermalEffects ~= "omit" ),  ...
message( "physmod:battery:builder:batteryclasses:CellThermalEffectsPSetBCMismatch" ) );
catch me
throwAsCaller( me )
end 
end 

if ~strcmp( val.StackingAxis, obj.StackingAxis )
obj.StackingAxisInternal = val.StackingAxis;
else 
end 

obj.CellInternal = val;
if ~isempty( obj.CellInternal.Geometry )
if strcmp( class( obj.CellInternal.Geometry ), "simscape.battery.builder.PouchGeometry" ) && obj.Rows > 1
obj.Rows = 1;
end 
end 
if strcmp( obj.Topology, "" ) && ~isempty( obj.CellInternal.Geometry )
switch class( obj.CellInternal.Geometry )
case "simscape.battery.builder.PouchGeometry"
obj.Topology = "SingleStack";
case "simscape.battery.builder.CylindricalGeometry"
obj.Topology = "Hexagonal";
case "simscape.battery.builder.PrismaticGeometry"
obj.Topology = "SingleStack";
end 
end 


obj = obj.updateLayout;
end 

function value = get.Cell( obj )
value = obj.CellInternal;
end 

function val = get.SimulationStrategyPatchDefinition( obj )
if isempty( obj.Cell.Elements ) ...
 || isempty( obj.Cell.Geometry ) ...
 || isempty( obj.Cell.Position )
val.faces = NaN;
val.vertices = NaN( 1, 2 );
val.facevertexcdata = NaN;
return 
end 
switch obj.ModelResolution
case "Detailed"
val = obj.BatteryPatchDefinition;
case "Lumped"
faces = [ "top", "bottom", "left", "right", "back", "front" ];
X.bottom = [ obj.PositionInternal.X, value( obj.XExtent, "m" ) ];
Y.bottom = [ obj.PositionInternal.Y, value( obj.YExtent, "m" ) ];
Z.bottom = repmat( obj.PositionInternal.Z, 2, 2 );

X.top = [ obj.PositionInternal.X, value( obj.XExtent, "m" ) ];
Y.top = [ obj.PositionInternal.Y, value( obj.YExtent, "m" ) ];
Z.top = repmat( value( obj.ZExtent, "m" ), 2, 2 );

X.back = [ obj.PositionInternal.X, value( obj.XExtent, "m" ) ];
Y.back = [ obj.PositionInternal.Y, obj.PositionInternal.Y ];
Z.back = [ [ obj.PositionInternal.Z, obj.PositionInternal.Z ]; ...
[ value( obj.ZExtent, "m" ), value( obj.ZExtent, "m" ) ] ];

X.front = [ obj.PositionInternal.X, value( obj.XExtent, "m" ) ];
Y.front = [ value( obj.YExtent, "m" ), value( obj.YExtent, "m" ) ];
Z.front = [ [ value( obj.ZExtent, "m" ), value( obj.ZExtent, "m" ) ]; ...
[ obj.PositionInternal.Z, obj.PositionInternal.Z ] ];

X.left = [ obj.PositionInternal.X, obj.PositionInternal.X ];
Y.left = [ value( obj.YExtent, "m" ), value( obj.YExtent, "m" ) ];
Z.left = [ [ obj.PositionInternal.Z, value( obj.ZExtent, "m" ) ]; ...
[ obj.PositionInternal.Z, value( obj.ZExtent, "m" ) ] ];

X.right = [ value( obj.XExtent, "m" ), value( obj.XExtent, "m" ) ];
Y.right = [ value( obj.YExtent, "m" ), value( obj.YExtent, "m" ) ];
Z.right = [ [ value( obj.ZExtent, "m" ), obj.PositionInternal.Z ]; ...
[ value( obj.ZExtent, "m" ), obj.PositionInternal.Z ] ];

for faceIdx = 1:length( faces )
thesePoints.X = X.( faces{ faceIdx } );
thesePoints.Y = Y.( faces{ faceIdx } );
thesePoints.Z = Z.( faces{ faceIdx } );
cdata = ones( size( thesePoints.Z ) );
if faceIdx == 1
[ FullX, FullY, FullZ, FullC ] = deal( [  ], [  ], [  ], [  ] );
end 
FullX = [ FullX;thesePoints.X';NaN ];%#ok<AGROW>
FullY = [ FullY;thesePoints.Y';NaN ];%#ok<AGROW>
FullZ = [ FullZ;[ [ NaN( 2, faceIdx * 3 - 3 ) ], thesePoints.Z, [ NaN( 2, ( length( faces ) * 3 - ( 3 * faceIdx - 1 ) ) ) ] ];NaN( 1, length( faces ) * 3 ) ];%#ok<AGROW>
FullC = [ FullC;[ [ NaN( 2, faceIdx * 3 - 3 ) ], cdata, [ NaN( 2, ( length( faces ) * 3 - ( 3 * faceIdx - 1 ) ) ) ] ];NaN( 1, length( faces ) * 3 ) ];%#ok<AGROW>
end 
val = surf2patch( FullX, FullY, FullZ, FullC );
end 
end 

function obj = set.InterCellGap( obj, val )
if strcmp( class( val ), "double" )
warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueMeters" ) )
val = simscape.Value( val, "m" );
end 
simscape.mustBeCommensurateUnit( val, "m" )
try 
assert( value( val, "m" ) <= 0.1,  ...
message( "physmod:battery:builder:batteryclasses:HighInterCellGap", "0.1" ) );
assert( value( val, "m" ) > 0,  ...
message( "physmod:battery:builder:batteryclasses:InvalidInterCellGap", "0" ) );
catch me
throwAsCaller( me )
end 
obj.InterCellGapInternal = val;

obj = obj.updateLayout;
end 

function value = get.InterCellGap( obj )
value = obj.InterCellGapInternal;
end 

function obj = set.BalancingStrategy( obj, val )
obj.BalancingStrategyInternal = val;
end 

function value = get.BalancingStrategy( obj )
value = obj.BalancingStrategyInternal;
end 

function obj = set.MassFactor( obj, val )
obj.MassFactorInternal = val;
end 

function value = get.MassFactor( obj )
value = obj.MassFactorInternal;
end 

function obj = set.AmbientThermalPath( obj, val )
try 
assert( obj.Cell.ThermalEffects ~= "omit" || strcmp( val, "" ),  ...
message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );
catch me
throwAsCaller( me )
end 
obj.AmbientThermalPathInternal = val;
end 

function value = get.AmbientThermalPath( obj )
value = obj.AmbientThermalPathInternal;
end 

function obj = set.CoolantThermalPath( obj, val )
try 
assert( obj.Cell.ThermalEffects ~= "omit" || strcmp( val, "" ),  ...
message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );
catch me
throwAsCaller( me )
end 
obj.CoolantThermalPathInternal = val;
end 

function value = get.CoolantThermalPath( obj )
value = obj.CoolantThermalPathInternal;
end 

function obj = set.CoolingPlate( obj, val )
try 
assert( obj.Cell.ThermalEffects ~= "omit" || any( strcmp( [ val ], "" ) ),  ...
message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );%#ok<NBRAK2>
assert( numel( val ) <= 2,  ...
message( "physmod:battery:builder:batteryclasses:InvalidCoolingPlateProperty", "2" ) );
assert( sum( double( strcmp( val, "Top" ) ) ) ~= 2 && sum( double( strcmp( val, "Bottom" ) ) ) ~= 2,  ...
message( "physmod:battery:builder:batteryclasses:RepeatedCoolingPlateLocation" ) );
catch me
throwAsCaller( me )
end 
obj.CoolingPlateInternal = val;
end 

function obj = set.StackingAxis( obj, val )
obj.Cell.StackingAxis = val;
obj.StackingAxisInternal = val;
obj = obj.updateLayout;
end 

function value = get.StackingAxis( obj )
value = obj.StackingAxisInternal;
end 

function value = get.CoolingPlate( obj )
value = obj.CoolingPlateInternal;
end 

function value = get.ThermalBoundaryConditions( obj )










Faces = [ "Top", "Bottom" ];
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
if isfield( value, ( Faces{ faceIdx } ) )
else 
value.( Faces{ faceIdx } ) = "Adiabatic";
end 
end 
end 
end 

function val = get.ThermalNodes( obj )
if strcmp( obj.Topology, "" )
val.Locations = [  ];
val.Dimensions = [  ];
val.NumNodes = [  ];
else 
TotalCellIdx = 1;
TotalGroupedModelIdx = 1;
DetailedCellNodeLocations = zeros( obj.NumParallelCells, 2 );
DetailedCellNodeDimensions = zeros( obj.NumParallelCells, 2 );
for CellIdx = 1:length( obj.CellRelativePositions )
thisPosition = obj.CellRelativePositions( CellIdx );
thesePoints = obj.CellPoints( CellIdx ).Points;
DetailedCellNodeLocations( TotalCellIdx, : ) = [ thisPosition.X, abs( thisPosition.Y ) ];
DetailedCellNodeDimensions( TotalCellIdx, : ) = [ ( max( max( abs( thesePoints.XData ) ) ) - min( min( abs( thesePoints.XData ) ) ) ), ( max( max( abs( thesePoints.YData ) ) ) - min( min( abs( thesePoints.YData ) ) ) ) ];
TotalCellIdx = TotalCellIdx + 1;
end 

if strcmp( obj.ModelResolution, "Detailed" )


CellNodeDimensions = DetailedCellNodeDimensions;
CellNodeLocations = DetailedCellNodeLocations;
elseif strcmp( obj.ModelResolution, "Lumped" )
CellNodeDimensions( TotalGroupedModelIdx, : ) = [ abs( value( obj.XExtent, "m" ) - obj.PositionInternal.X ),  ...
abs( value( obj.YExtent, "m" ) - obj.PositionInternal.Y ) ];
CellNodeLocations( TotalGroupedModelIdx, : ) = [ mean( DetailedCellNodeLocations( :, 1 ) ),  ...
mean( DetailedCellNodeLocations( :, 2 ) ) ];
end 
if any( contains( obj.CoolingPlate, "Top" ) )
val.Top.Locations = CellNodeLocations;
val.Top.Dimensions = CellNodeDimensions;
val.Top.NumNodes = length( CellNodeLocations( :, 1 ) );
end 
if any( contains( obj.CoolingPlate, "Bottom" ) )
val.Bottom.Locations = CellNodeLocations;
val.Bottom.Dimensions = CellNodeDimensions;
val.Bottom.NumNodes = length( CellNodeLocations( :, 1 ) );
end 
if ~any( contains( obj.CoolingPlate, "Top" ) ) || ~any( contains( obj.CoolingPlate, "Bottom" ) )
val.Locations = CellNodeLocations;
val.Dimensions = CellNodeDimensions;
val.NumNodes = length( CellNodeLocations( :, 1 ) );
end 
end 
end 

function value = get.Columns( obj )

if isempty( obj.Cell.Format )
else 
if strcmp( obj.Cell.Format, "Cylindrical" )
value = ceil( obj.NumParallelCells / obj.Rows );
elseif strcmp( obj.Cell.Format, "Primatic" )
else 
value = obj.NumParallelCells;
end 
end 
end 

function obj = set.ModelResolution( obj, val )
obj.ModelResolutionInternal = val;
end 

function value = get.ModelResolution( obj )
value = obj.ModelResolutionInternal;
end 

function obj = set.Topology( obj, val )
if strcmp( obj.Cell.Format, "" ) && ~strcmp( val, "" )
try 
assert( ~strcmp( obj.Cell.Format, "" ),  ...
message( "physmod:battery:builder:batteryclasses:TopologyMismatchWithEmptyCellFormat" ) );
catch me
throwAsCaller( me )
end 
elseif strcmp( obj.Cell.Format, "" )
try 
assert( ~isempty( obj.Cell.Format ),  ...
message( "physmod:battery:builder:batteryclasses:TopologyMismatchWithEmptyCellFormat" ) );
catch me
throwAsCaller( me )
end 
else 
if strcmp( val, "" ) && obj.Cell.Format ~= ""

else 
try 
assert( ( obj.Cell.Format ~= "Prismatic" ) || ( ( val ~= "Hexagonal" ) && ( val ~= "Square" ) ),  ...
message( "physmod:battery:builder:batteryclasses:TopologyMismatchWithCellFormat" ) );
assert( ( obj.Cell.Format ~= "Pouch" ) || ( ( val ~= "Hexagonal" ) && ( val ~= "Square" ) ),  ...
message( "physmod:battery:builder:batteryclasses:TopologyMismatchWithCellFormat" ) );
assert( ( obj.Cell.Format ~= "Cylindrical" ) || ( ( val ~= "SingleStack" ) && ( val ~= "NStack" ) ),  ...
message( "physmod:battery:builder:batteryclasses:TopologyMismatchWithCellFormat" ) );
catch me
throwAsCaller( me )
end 
end 
end 
if strcmp( obj.Cell.Format, "Cylindrical" ) && strcmp( val, "" )
obj.TopologyInternal = "Hexagonal";
elseif strcmp( obj.Cell.Format, "Prismatic" ) && strcmp( val, "" )
obj.TopologyInternal = "SingleStack";
elseif strcmp( obj.Cell.Format, "Pouch" ) && strcmp( val, "" )
obj.TopologyInternal = "SingleStack";
elseif isempty( obj.Cell.Format )
obj.TopologyInternal = "";
else 
obj.TopologyInternal = val;
end 
obj = obj.updateLayout;
end 

function value = get.Topology( obj )
value = obj.TopologyInternal;
end 

function value = get.CellRelativePositions( obj )
if obj.PositionInternal.X == 0 &&  ...
obj.PositionInternal.Y == 0 &&  ...
obj.PositionInternal.Z == 0
value = obj.CellCenterPositions;
else 
for CellIdx = 1:length( obj.CellCenterPositions )
thisPosition = obj.CellCenterPositions( CellIdx );
CellRelPos( CellIdx ) = simscape.battery.builder.internal.Position( X = thisPosition.X - obj.PositionInternal.X,  ...
Y = thisPosition.Y - obj.PositionInternal.Y, Z = thisPosition.Z - obj.PositionInternal.Z );%#ok<AGROW>
end 
value = CellRelPos;
end 
end 

function val = get.PackagingVolume( obj )
if isempty( obj.XExtent )
val = simscape.Value( [  ], "m^3" );
else 
thesePoints = [ obj.CellPoints.Points ];
[ X, Y, Z ] = deal( max( [ thesePoints.XData ], [  ], "all" ) - min( [ thesePoints.XData ], [  ], "all" ),  ...
min( [ thesePoints.YData ], [  ], "all" ) - max( [ thesePoints.YData ], [  ], "all" ),  ...
max( [ thesePoints.ZData ], [  ], "all" ) - min( [ thesePoints.ZData ], [  ], "all" ) );
val = simscape.Value( abs( X * Y * Z ), "m^3" );
end 
end 

function value = get.CumulativeMass( obj )
value = obj.Cell.Mass * obj.NumParallelCells * obj.MassFactor;
end 

function value = get.SimulationToHardwareMapping( obj )
BatteryTypes = [ "ParallelAssembly", "Cell", "Model" ];
SimulationToHardware( :, 1 ) = ones( obj.NumParallelCells, 1 );
SimulationToHardware( :, 2 ) = ( 1:1:obj.NumParallelCells )';
if strcmp( obj.ModelResolution, "Lumped" )
SimulationToHardware( :, 3 ) = SimulationToHardware( :, 1 );
else 
SimulationToHardware( :, 3 ) = SimulationToHardware( :, 2 );
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
if strcmp( obj.Cell.Format, "" )
value = simscape.Value( [  ], "m" );
else 
allPoints = [ obj.CellPoints( 1:end  ).Points ];
if strcmp( axisExtentName, "YData" )
value = simscape.Value( min( min( ( [ allPoints.( axisExtentName ) ] ) ) ), "m" );
else 
value = simscape.Value( max( max( abs( [ allPoints.( axisExtentName ) ] ) ) ), "m" );
end 
end 
end 
end 

methods ( Access = private )

function obj = updateLayout( obj )
obj.Layout = obj.getLayoutArray;
obj.CellNumbering.ParallelAssembly = 1;
obj.CellNumbering.Cells = obj.Layout;


obj = obj.updateCellColors;
obj = obj.updatePositions;
obj = obj.updateCellPoints;
end 

function obj = updateCellColors( obj )
obj.CellColors = repmat( simscape.battery.builder.internal.StateVariable, obj.NumParallelCells, 1 );
end 

function obj = updatePositions( obj )
obj.CellPositions = repmat( simscape.battery.builder.internal.Position, obj.NumParallelCells, 1 );
obj.CellCenterPositions = repmat( simscape.battery.builder.internal.Position, obj.NumParallelCells, 1 );
switch obj.Topology
case "Square"
obj = updateSquarePositions( obj );
case "Hexagonal"
obj = updateHexagonalPositions( obj );
case "SingleStack"
obj = updateSingleStackPositions( obj );
case "NStack"
obj = updateNStackPositions( obj );
end 
end 

function obj = updateCellPoints( obj )
obj.CellPoints = [  ];

if isempty( obj.Cell.Elements ) ...
 || isempty( obj.Cell.Geometry ) ...
 || isempty( obj.Cell.Position )
obj.BatteryPatchDefinition.faces = NaN;
obj.BatteryPatchDefinition.vertices = NaN( 1, 2 );
obj.BatteryPatchDefinition.facevertexcdata = NaN;
return 
end 
pSetPatch = struct( "faces", double.empty( 0, 4 ), "vertices", double.empty( 0, 3 ), "facevertexcdata", double.empty( 0, 1 ) );
for cellIdx = 1:length( obj.CellPositions )
obj.CellPoints( cellIdx ).Points = simscape.battery.builder.internal.Points( obj.CellPositions( cellIdx ).X + obj.Cell.Points.XData,  ...
obj.CellPositions( cellIdx ).Y + obj.Cell.Points.YData,  ...
obj.CellPositions( cellIdx ).Z + obj.Cell.Points.ZData );
cdata = obj.CellColors( cellIdx, 1 ).getCData( obj.CellPoints( cellIdx ).Points );
cellPatch = surf2patch( obj.CellPoints( cellIdx ).Points.XData, obj.CellPoints( cellIdx ).Points.YData, obj.CellPoints( cellIdx ).Points.ZData, cdata{ : } );
if cellIdx == 1
maxFaceValue = 0;
else 
maxFaceValue = max( pSetPatch.faces( : ) );
end 
pSetPatch.faces = [ pSetPatch.faces;cellPatch.faces + maxFaceValue ];
pSetPatch.vertices = [ pSetPatch.vertices;cellPatch.vertices ];
pSetPatch.facevertexcdata = [ pSetPatch.facevertexcdata;cellPatch.facevertexcdata ];
clear cellPatch
end 


obj.BatteryPatchDefinition = pSetPatch;
end 

function [ obj ] = updateSquarePositions( obj )
Radius = value( obj.Cell.Geometry.Radius, "m" );
if isempty( obj.Position )
[ initialPoint.X, initialPoint.Y, initialPoint.Z ] = deal( 0, 0, 0 );
else 
initialPoint = obj.PositionInternal;
end 
cellRadius = Radius;
cellDiameter = 2 * cellRadius;
interCellGap = value( obj.InterCellGap, "m" );
InterParallelAssemblyGapArray = obj.InterParallelAssemblyGapFcn( obj );
if strcmp( obj.StackingAxis, "X" )
locationY =  - ( 0:( cellDiameter + interCellGap ):( obj.Rows - 1 ) * ( cellDiameter + interCellGap ) ) + initialPoint.Y;
locationX = ( ( 0:( cellDiameter + interCellGap ):( obj.Columns - 1 ) * ( cellDiameter + interCellGap ) ) +  ...
initialPoint.X );
else 
locationX = ( 0:( cellDiameter + interCellGap ):( obj.Rows - 1 ) * ( cellDiameter + interCellGap ) ) + initialPoint.X;
locationY =  - ( ( 0:( cellDiameter + interCellGap ):( obj.Columns - 1 ) * ( cellDiameter + interCellGap ) ) -  ...
initialPoint.Y );
end 
locationZ = initialPoint.Z;
for cellIdx = 1:length( obj.CellPositions )
[ rowIdx, columnIdx ] = find( obj.Layout == cellIdx );
if strcmp( obj.StackingAxis, "X" )
[ thisX, thisY, thisZ ] = deal( ( locationX( columnIdx ) + InterParallelAssemblyGapArray( rowIdx, columnIdx ) ), locationY( rowIdx ), locationZ );
else 
[ thisX, thisY, thisZ ] = deal( locationX( rowIdx ), locationY( columnIdx ) - InterParallelAssemblyGapArray( rowIdx, columnIdx ), locationZ );
end 
obj.CellPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX, Y = thisY, Z = thisZ );
obj.CellCenterPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX + Radius, Y = thisY - Radius, Z = thisZ );
end 
end 

function [ obj ] = updateHexagonalPositions( obj, varargin )
Radius = value( obj.Cell.Geometry.Radius, "m" );
if isempty( obj.Position )
[ initialPoint.X, initialPoint.Y, initialPoint.Z ] = deal( 0, 0, 0 );
else 
initialPoint = obj.PositionInternal;
end 
cellRadius = Radius;
cellDiameter = 2 * cellRadius;
interCellGap = value( obj.InterCellGap, "m" );
deltaX = ( cellDiameter + interCellGap ) * sqrt( 3 ) / 2;
InterParallelAssemblyGapArray = obj.InterParallelAssemblyGapFcn( obj );
if strcmp( obj.StackingAxis, "X" )
locationXOdd = ( ( 0:( cellDiameter + interCellGap ):( obj.Columns - 1 ) * ( cellDiameter + interCellGap ) ) ...
 + initialPoint.X );
locationXEven = locationXOdd + ( ( cellDiameter + interCellGap ) / 2 );
locationY =  - ( 0:( deltaX ):( obj.Rows - 1 ) * ( cellDiameter + interCellGap ) ) + initialPoint.Y;
else 
locationYOdd =  - ( ( 0:( cellDiameter + interCellGap ):( obj.Columns - 1 ) * ( cellDiameter + interCellGap ) ) ...
 - initialPoint.Y );
locationYEven = locationYOdd - ( ( cellDiameter + interCellGap ) / 2 );
locationX =  + ( 0:( deltaX ):( obj.Rows - 1 ) * ( cellDiameter + interCellGap ) ) + initialPoint.X;
end 
locationZ = initialPoint.Z;
for cellIdx = 1:length( obj.CellPositions )
[ rowIdx, columnIdx ] = find( obj.Layout == cellIdx );
if strcmp( obj.StackingAxis, "X" )
if rem( rowIdx, 2 ) == 1
locationX = locationXOdd + InterParallelAssemblyGapArray( rowIdx, columnIdx );
else 
locationX = locationXEven + InterParallelAssemblyGapArray( rowIdx, columnIdx );
end 
[ thisX, thisY, thisZ ] = deal( locationX( columnIdx ) + InterParallelAssemblyGapArray( rowIdx, columnIdx ), locationY( rowIdx ), locationZ );
else 
if rem( rowIdx, 2 ) == 1
locationY = locationYOdd - InterParallelAssemblyGapArray( rowIdx, columnIdx );
else 
locationY = locationYEven - InterParallelAssemblyGapArray( rowIdx, columnIdx );
end 
[ thisX, thisY, thisZ ] = deal( locationX( rowIdx ), locationY( columnIdx ) - InterParallelAssemblyGapArray( rowIdx, columnIdx ), locationZ );
end 
obj.CellPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX, Y = thisY, Z = thisZ );
obj.CellCenterPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = ( thisX + Radius ), Y = ( thisY - Radius ), Z = thisZ );
end 
end 

function [ obj ] = updateSingleStackPositions( obj, varargin )
cellThickness = value( obj.Cell.Geometry.Thickness, "m" );
cellLength = value( obj.Cell.Geometry.Length, "m" );
if isempty( obj.Position )
[ initialPoint.X, initialPoint.Y, initialPoint.Z ] = deal( 0, 0, 0 );
else 
initialPoint = obj.PositionInternal;
end 
interCellGap = value( obj.InterCellGap, "m" );
InterParallelAssemblyGapArray = obj.InterParallelAssemblyGapFcn( obj );
switch obj.Cell.Format
case "Pouch"
switch obj.Cell.Geometry.TabLocation
case "Opposed"
locationX = initialPoint.X + value( obj.Cell.Geometry.TabHeight, "m" );
case "Standard"
locationX = initialPoint.X;
end 
case "Prismatic"
locationX = initialPoint.X;
end 
if strcmp( obj.StackingAxis, "X" )
locationX = ( ( 0:( cellThickness + interCellGap ):( obj.Columns - 1 ) * ( cellThickness + interCellGap ) ) ) ...
 + initialPoint.X;
locationY = initialPoint.Y;
else 
locationY =  - ( ( 0:( cellThickness + interCellGap ):( obj.Columns - 1 ) * ( cellThickness + interCellGap ) ) ) ...
 + initialPoint.Y;
end 
locationZ = initialPoint.Z;
for cellIdx = 1:length( obj.CellPositions )
[ rowIdx, columnIdx ] = find( obj.Layout == cellIdx );
if strcmp( obj.StackingAxis, "X" )
[ thisX, thisY, thisZ ] = deal( locationX( columnIdx ) + InterParallelAssemblyGapArray( rowIdx, columnIdx ), locationY( rowIdx ), locationZ );
else 
[ thisX, thisY, thisZ ] = deal( locationX( rowIdx ), locationY( columnIdx ) - InterParallelAssemblyGapArray( rowIdx, columnIdx ), locationZ );
end 
obj.CellPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX, Y = thisY, Z = thisZ );
if strcmp( obj.StackingAxis, "X" )
obj.CellCenterPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX + cellThickness / 2, Y = thisY - cellLength / 2, Z = thisZ );
else 
obj.CellCenterPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX + cellLength / 2, Y = thisY - cellThickness / 2, Z = thisZ );
end 
end 
end 

function [ obj ] = updateNStackPositions( obj, varargin )
cellLength = value( obj.Cell.Geometry.Length, "m" );
cellThickness = value( obj.Cell.Geometry.Thickness, "m" );
if isempty( obj.Position )
[ initialPoint.X, initialPoint.Y, initialPoint.Z ] = deal( 0, 0, 0 );
else 
initialPoint = obj.PositionInternal;
end 
interCellGap = value( obj.InterCellGap, "m" );
InterParallelAssemblyGapArray = obj.InterParallelAssemblyGapFcn( obj );
locationX = ( 0:( cellLength + interCellGap ):( obj.Rows - 1 ) * ( cellLength + interCellGap ) ) + initialPoint.X;
locationY =  - ( ( 0:( cellThickness + interCellGap ):( obj.Columns - 1 ) * ( cellThickness + interCellGap ) ) ...
 - initialPoint.Y );
locationZ = initialPoint.Z;
for cellIdx = 1:length( obj.CellPositions )
[ rowIdx, columnIdx ] = find( obj.Layout == cellIdx );
if strcmp( obj.StackingAxis, "X" )
[ thisX, thisY, thisZ ] = deal( locationY( columnIdx ) - InterParallelAssemblyGapArray( rowIdx, columnIdx ), locationX( rowIdx ), locationZ );
else 
[ thisX, thisY, thisZ ] = deal( locationX( rowIdx ), locationY( columnIdx ) - InterParallelAssemblyGapArray( rowIdx, columnIdx ), locationZ );
end 
obj.CellPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX, Y = thisY, Z = thisZ );
if strcmp( obj.StackingAxis, "X" )
obj.CellCenterPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX + cellThickness / 2, Y = thisY - cellLength / 2, Z = thisZ );
else 
obj.CellCenterPositions( cellIdx ) = simscape.battery.builder.internal.Position( X = thisX + cellLength / 2, Y = thisY - cellThickness / 2, Z = thisZ );
end 
end 
end 

function Layout = getLayoutArray( obj )









Layout = reshape( 1:obj.Rows * ceil( obj.NumParallelCells / obj.Rows ), obj.Rows, ceil( obj.NumParallelCells / obj.Rows ) );

if isempty( obj.Cell.Format )
else 
if strcmp( obj.Cell.Format, "Cylindrical" )
MissingNoCells = mod( obj.NumParallelCells, obj.Rows );
if MissingNoCells ~= 0
MissingNoCellsIdx = obj.NumParallelCells - MissingNoCells + 1;
endColumnLayout = round( linspace( MissingNoCellsIdx, obj.NumParallelCells, obj.Rows ) );
endColumnLayout = obj.remainderCellLocFcn( obj, MissingNoCells, endColumnLayout );
Layout( :, end  ) = endColumnLayout;
else 

end 
elseif strcmp( obj.Cell.Format, "Prismatic" ) && strcmp( obj.Topology, "NStack" )
MissingNoCells = mod( obj.NumParallelCells, obj.Rows );
if MissingNoCells ~= 0
MissingNoCellsIdx = obj.NumParallelCells - MissingNoCells + 1;
endColumnLayout = round( linspace( MissingNoCellsIdx, obj.NumParallelCells, obj.Rows ) );
endColumnLayout = obj.remainderCellLocFcn( obj, MissingNoCells, endColumnLayout );
Layout( :, end  ) = endColumnLayout;
else 

end 
elseif strcmp( obj.Cell.Format, "Prismatic" ) || strcmp( obj.Cell.Format, "Pouch" )

end 
end 
end 

end 

methods ( Access = protected )
function propgrp = getPropertyGroups( ~ )
propList = [ "NumParallelCells", "Cell", "Topology", "Rows", "ModelResolution" ];
propgrp = matlab.mixin.util.PropertyGroup( propList );
end 
end 

methods ( Static, Hidden )
function endColumnLayout = remainderCellLocFcn( obj, MissingNoCells, endColumnLayout )
NoEvenPositions = sum( ~rem( 1:obj.Rows, 2 ) );
NoOddPositions = obj.Rows - NoEvenPositions;
switch obj.Type
case "ParallelAssembly"
RemainderCellPositions = obj.RemainderCellPositions;
case "Module"
RemainderCellPositions = obj.ParallelAssembly.RemainderCellPositions;
end 
switch RemainderCellPositions
case "Odd"
if NoOddPositions > MissingNoCells
for i = 1:obj.Rows
if mod( i, 2 ) ~= 0
else 
endColumnLayout( i ) = NaN;
end 
end 
else 
end 
[ ~, idx, ~ ] = unique( endColumnLayout, "stable" );
endColumnLayout( setdiff( 1:numel( endColumnLayout ), idx ) ) = NaN;
endColumnLayout( isnan( endColumnLayout ) ) = 0;
case "Even"
if NoEvenPositions > MissingNoCells
for i = 1:obj.Rows
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



P = obj.NumParallelCells;
Layout = obj.Layout;
S = 1;
InterParallelAssemblyGap = 0;
InterParallelAssemblyGapArray = zeros( size( Layout ) );
ParallelAssemblyfactor = 0;
for i = 1:S
InterParallelAssemblyGapArray( obj.Layout > ( i - 1 ) * P & Layout <= i * P & Layout ~= 0 ) = InterParallelAssemblyGap * ParallelAssemblyfactor;
ParallelAssemblyfactor = ParallelAssemblyfactor + 1;
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpleTluH.p.
% Please follow local copyright laws when handling this file.

