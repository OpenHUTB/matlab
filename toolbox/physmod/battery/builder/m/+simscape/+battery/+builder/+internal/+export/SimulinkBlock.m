classdef ( Sealed = true, Hidden = true )SimulinkBlock < simscape.battery.builder.internal.export.Block




properties ( Constant )
BlockType = "SimulinkBlock";
end 

properties ( GetAccess = public, SetAccess = immutable )
BlockPath
end 

methods 
function obj = SimulinkBlock( identifier, blockParameters, blockPath )
obj.Identifier = identifier;
obj.BlockParameters = [ obj.BlockParameters;blockParameters ];
obj.BlockPath = blockPath;
end 

function obj = setBatteryType( obj, batteryType )

R36
obj( 1, 1 ){ mustBeA( obj, "simscape.battery.builder.internal.export.SimulinkBlock" ) }
batteryType string{ mustBeMember( batteryType, [ "ModuleAssembly", "Pack" ] ) }
end 
obj.BatteryType = batteryType;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpsSldOr.p.
% Please follow local copyright laws when handling this file.

