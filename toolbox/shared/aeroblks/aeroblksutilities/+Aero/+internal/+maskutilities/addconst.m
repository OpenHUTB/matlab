function addconst( blk, value, NameValues )









R36
blk
value( 1, 1 )string
NameValues.DataType( 1, 1 )string = "Inherit: Inherit via back propagation"
end 


if get_param( blk, 'blockType' ) ~= "Constant"
pos = get_param( blk, 'Position' );
delete_block( blk );
add_block( 'built-in/Constant', blk,  ...
Position = pos,  ...
Value = value,  ...
OutDataTypeStr = NameValues.DataType );
else 
set_param( blk, 'Value', value )
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMix4DR.p.
% Please follow local copyright laws when handling this file.

