function addport( blk, porttype, port, NameValues )

arguments
    blk
    porttype( 1, 1 )string{ mustBeMember( porttype, [ "Outport", "Inport" ] ) }
    port( 1, 1 )string
    NameValues.OutUnit( 1, 1 )string = getUnit( blk )
    NameValues.Dimensions( 1, 1 )string = "-1";
    NameValues.DataType( 1, 1 )string = "Inherit: auto";
end


if get_param( blk, 'BlockType' ) ~= porttype
    pos = get_param( blk, 'Position' );
    delete_block( blk );
    add_block( "built-in/" + porttype, blk,  ...
        Position = pos,  ...
        ShowName = "on",  ...
        Port = port,  ...
        OutUnit = NameValues.OutUnit,  ...
        OutDataTypeStr = NameValues.DataType,  ...
        PortDimensions = NameValues.Dimensions );
else

    Aero.internal.maskutilities.shortCircuitSetParam( blk,  ...
        Port = port,  ...
        OutUnit = NameValues.OutUnit,  ...
        OutDataTypeStr = NameValues.DataType,  ...
        PortDimensions = NameValues.Dimensions );
end

end

function unit = getUnit( blk )
if get_param( blk, 'BlockType' ) == "Inport"

    unit = get_param( blk, 'OutUnit' );
else
    unit = 'inherit';
end
end
