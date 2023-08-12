classdef Plugin < handle





properties ( GetAccess = public, SetAccess = private )
Name
Type
Function
end 

methods 
function this = Plugin( name, type, func )
R36
name( 1, 1 )coder.internal.rte.PluginName
type( 1, 1 )coder.internal.rte.PluginType
func( 1, 1 )function_handle
end 
this.Name = name;
this.Type = type;
this.Function = func;
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpcvgcHO.p.
% Please follow local copyright laws when handling this file.

