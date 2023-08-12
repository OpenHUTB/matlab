classdef EventScope











emumeration 


Scoped

Global
end 

methods ( Static = true, Hidden = true )
function externalScopeType = toExternalScopeType( internalScopeType )
R36
internalScopeType( 1, 1 )sltp.mm.core.EventScope
end 

switch internalScopeType
case sltp.mm.core.EventScope.Global
externalScopeType = simulink.schedule.EventScope.Global;
case sltp.mm.core.EventScope.Scoped
externalScopeType = simulink.schedule.EventScope.Scoped;
otherwise 
assert( false, "Internal error. Unsupported event scope type detected" );
end 
end 

function internalScopeType = toInternalScopeType( externalScopeType )
R36
externalScopeType( 1, 1 )simulink.schedule.EventScope
end 

switch externalScopeType
case simulink.schedule.EventScope.Global
internalScopeType = sltp.mm.core.EventScope.Global;
case simulink.schedule.EventScope.Scoped
internalScopeType = sltp.mm.core.EventScope.Scoped;
otherwise 
assert( false, "Internal error. Unsupported event scope type detected" );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRZtA53.p.
% Please follow local copyright laws when handling this file.

