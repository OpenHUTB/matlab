classdef FunctionCallThrottler < handle



properties ( SetAccess = immutable )
FunctionHandle
Rate
end 

properties ( Access = private )
LastTic
end 

properties ( Constant, Access = private )
NOPFunction = @(  )[  ]
end 

methods 
function obj = FunctionCallThrottler( fcnHandle, rate )
R36
fcnHandle( 1, 1 )function_handle = MultiSim.internal.FunctionCallThrottler.NOPFunction
rate( 1, 1 )double = 1
end 

obj.FunctionHandle = fcnHandle;
obj.Rate = rate;
obj.LastTic = tic;
end 

function call( obj, fcnArgs, namedArgs )



R36
obj
fcnArgs cell = {  }
namedArgs.Force( 1, 1 )logical = false
end 

if namedArgs.Force || ( toc( obj.LastTic ) >= obj.Rate )
obj.LastTic = tic;
obj.FunctionHandle( fcnArgs{ : } );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpULLInF.p.
% Please follow local copyright laws when handling this file.

