function addstub( blk, stubtype )

arguments
    blk
    stubtype( 1, 1 )string{ mustBeMember( stubtype, [ "Terminator", "Ground" ] ) }
end

if get_param( blk, 'BlockType' ) ~= stubtype
    pos = get_param( blk, 'Position' );
    delete_block( blk );
    add_block( "built-in/" + stubtype, blk, 'Position', pos, 'showName', 'off' );
end

end
