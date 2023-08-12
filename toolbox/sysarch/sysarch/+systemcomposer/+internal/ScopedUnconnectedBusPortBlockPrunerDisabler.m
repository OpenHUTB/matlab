classdef ScopedUnconnectedBusPortBlockPrunerDisabler < handle





properties 
bd;
end 

methods 
function this = ScopedUnconnectedBusPortBlockPrunerDisabler( modelNameOrHandle )
this.bd = get_param( modelNameOrHandle, 'handle' );
Simulink.Editor.UnconnectedBusPortBlockPruner.disable( this.bd );
end 

function delete( this )
Simulink.Editor.UnconnectedBusPortBlockPruner.enable( this.bd );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmps53Hlg.p.
% Please follow local copyright laws when handling this file.

