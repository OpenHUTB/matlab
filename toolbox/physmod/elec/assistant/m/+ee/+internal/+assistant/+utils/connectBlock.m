function connectBlock(blockName)


    parentName=get_param(blockName,'Parent');
    blockPortConnectivity=get_param(blockName,'PortConnectivity');
    blockPortPosition=blockPortConnectivity.Position;


    connection=ee.internal.assistant.utils.findConnection(blockName,'nearest');
    lineCoordinate=ee.internal.assistant.utils.findLineCoordinate(connection);


    add_line(parentName,[blockPortPosition;lineCoordinate]);
end