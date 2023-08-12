function tf = isVariantComponent( hdl )




tf = strcmp( get_param( hdl, 'BlockType' ), 'SubSystem' ) &&  ...
strcmp( get_param( hdl, 'Variant' ), 'on' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXg2kjn.p.
% Please follow local copyright laws when handling this file.

