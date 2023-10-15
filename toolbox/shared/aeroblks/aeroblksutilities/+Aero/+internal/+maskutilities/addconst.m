function addconst( blk, value, NameValues )

arguments
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
