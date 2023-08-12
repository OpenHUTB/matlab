classdef ( Sealed = true, Hidden = true )BlockDatabase




properties ( Access = private )
Blocks = simscape.battery.builder.internal.export.SimscapeBlock.empty( 0, 1 );
end 

methods 
function obj = addBlock( obj, block )
R36
obj( 1, 1 )simscape.battery.builder.internal.export.BlockDatabase
block( 1, 1 ){ mustBeA( block, [ "simscape.battery.builder.internal.export.SimulinkBlock", "simscape.battery.builder.internal.export.SimscapeBlock" ] ) }
end 
existingBlock = obj.getBlockByBatteryTypeAndId( block.BatteryType, block.Identifier );
assert( isempty( existingBlock ), message( "physmod:battery:builder:export:BlockExistisInDatabase" ) );
obj.Blocks = [ obj.Blocks, block ];
end 

function block = getBlock( obj, batteryType, identifier )
R36
obj( 1, 1 )simscape.battery.builder.internal.export.BlockDatabase
batteryType string{ mustBeTextScalar( batteryType ) }
identifier string{ mustBeTextScalar( identifier ) }
end 
block = obj.getBlockByBatteryTypeAndId( batteryType, identifier );
assert( ~isempty( block ), message( "physmod:battery:builder:export:BlockUnavailableInDatabase", batteryType, identifier ) );

end 

function obj = setSimscapeBlocksLibraryName( obj, libraryName )

R36
obj( 1, 1 )simscape.battery.builder.internal.export.BlockDatabase
libraryName string{ mustBeValidVariableName( libraryName ) }
end 
simscapeBlocks = strcmp( [ obj.Blocks.BlockType ], "SimscapeBlock" );
obj.Blocks( simscapeBlocks ) = obj.Blocks( simscapeBlocks ).setSimulinkLibraryName( libraryName );
end 
end 

methods ( Access = private )
function block = getBlockByBatteryTypeAndId( obj, batteryType, identifier )

blockHasBatteryType = string( [ obj.Blocks.BatteryType ] ) == batteryType;
blockHasIdentifier = string( [ obj.Blocks.Identifier ] ) == identifier;
isBlock = blockHasBatteryType & blockHasIdentifier;
block = obj.Blocks( isBlock );
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpDfVlcq.p.
% Please follow local copyright laws when handling this file.

