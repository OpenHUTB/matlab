classdef TemporarySetParam < handle













properties 
ConfigSet
Param
OriginalValue
Enabled = [  ]
end 

methods 
function obj = TemporarySetParam( cs, param, value, options )
R36
cs( 1, 1 )handle
param( 1, 1 )string
value
options.Enable( 1, 1 )matlab.lang.OnOffSwitchState = "off"
end 



obj.ConfigSet = cs;
obj.Param = param;
obj.OriginalValue = get_param( cs, param );

if options.Enable

obj.Enabled = cs.getPropEnabled( param );
cs.setPropEnabled( param, true );
end 


set_param( cs, param, value );
end 

function delete( obj )

cs = obj.ConfigSet;
if ishandle( cs )


set_param( cs, obj.Param, obj.OriginalValue );
if islogical( obj.Enabled )
cs.setPropEnabled( obj.Param, obj.Enabled );
end 
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpLvxZ7U.p.
% Please follow local copyright laws when handling this file.

