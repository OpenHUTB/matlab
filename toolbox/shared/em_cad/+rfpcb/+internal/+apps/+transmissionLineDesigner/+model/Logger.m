classdef Logger < handle







properties ( SetAccess = private )
Stack( :, 1 )cell
ReproductionStack( :, 1 )cell
end 

properties 
Display( 1, 1 ){ mustBeNumericOrLogical } = false;
LoadingTime( 1, 1 )double{ mustBeNumeric }
end 

methods 
function obj = Logger( options )



R36
options.Display( 1, 1 ){ mustBeNumericOrLogical } = false;
end 
obj.Display = options.Display;
end 

function log( obj, action )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger{ mustBeNonempty }
action{ mustBeText, mustBeNonempty }
end 

obj.Stack{ end  + 1 } = action;
if obj.Display
disp( action )
end 
end 

function debug( obj, command )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger{ mustBeNonempty }
command{ mustBeText, mustBeNonempty }
end 

obj.ReproductionStack{ end  + 1 } = command;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpJVO4EH.p.
% Please follow local copyright laws when handling this file.

