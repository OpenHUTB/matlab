



























classdef SimulationCallback < handle
methods ( Access = private )
function obj = SimulationCallback(  )
end 
end 
properties ( Constant, Access = private )
Instance = SimBiology.function.internal.SimulationCallback(  )
end 
properties 
CallbackFcn
end 
methods ( Static )
function clear(  )
instance = SimBiology.function.internal.SimulationCallback.Instance;
instance.CallbackFcn = [  ];
end 
function set( fcn )
R36
fcn function_handle
end 
instance = SimBiology.function.internal.SimulationCallback.Instance;
instance.CallbackFcn = fcn;
end 
function fcn = get(  )
instance = SimBiology.function.internal.SimulationCallback.Instance;
fcn = instance.CallbackFcn;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmprFImjb.p.
% Please follow local copyright laws when handling this file.

