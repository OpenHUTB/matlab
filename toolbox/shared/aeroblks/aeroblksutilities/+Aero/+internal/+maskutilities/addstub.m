function addstub( blk, stubtype )









R36
blk
stubtype( 1, 1 )string{ mustBeMember( stubtype, [ "Terminator", "Ground" ] ) }
end 

if get_param( blk, 'BlockType' ) ~= stubtype
pos = get_param( blk, 'Position' );
delete_block( blk );
add_block( "built-in/" + stubtype, blk, 'Position', pos, 'showName', 'off' );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp19HjBk.p.
% Please follow local copyright laws when handling this file.

