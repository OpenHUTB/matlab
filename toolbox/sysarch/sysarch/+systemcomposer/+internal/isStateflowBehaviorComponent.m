function tf = isStateflowBehaviorComponent( hdl )




tf = false;
if strcmp( get_param( hdl, 'BlockType' ), 'SubSystem' ) && strcmp( get_param( hdl, 'SFBlockType' ), 'Chart' )
archPeer = systemcomposer.utils.getArchitecturePeer( hdl );
if ~isempty( archPeer ) && isa( archPeer.getArchitecture, 'systemcomposer.architecture.model.sldomain.StateflowArchitecture' )
tf = true;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3hLuQ9.p.
% Please follow local copyright laws when handling this file.

