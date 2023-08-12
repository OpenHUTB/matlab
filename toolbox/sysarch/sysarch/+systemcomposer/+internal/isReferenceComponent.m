function tf = isReferenceComponent( hdl )



tf = strcmp( get_param( hdl, 'BlockType' ), 'ModelReference' ) ||  ...
systemcomposer.internal.isSubsystemReferenceComponent( hdl );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwy7ooq.p.
% Please follow local copyright laws when handling this file.

