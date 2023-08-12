classdef ( Abstract )ConfigOption < matlab.mixin.Heterogeneous




properties ( Abstract, Constant, Access = protected )

CompatibleProfilerType
end 

methods 
function compatible = isCompatible( obj, profilerType )



R36
obj
profilerType( 1, 1 )matlab.internal.profiler.ProfilerType
end 

compatible = isequal( profilerType, obj.CompatibleProfilerType );
end 
end 

methods ( Abstract, Static )



out = isTypeOf( option )
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp0eDObd.p.
% Please follow local copyright laws when handling this file.

