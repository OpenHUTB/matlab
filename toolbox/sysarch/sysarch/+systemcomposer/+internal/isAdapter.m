function tf = isAdapter( hdl )



tf = strcmp( get_param( hdl, 'BlockType' ), 'SubSystem' ) &&  ...
strcmp( get_param( hdl, 'SimulinkSubDomain' ), 'ArchitectureAdapter' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1_twc4.p.
% Please follow local copyright laws when handling this file.

