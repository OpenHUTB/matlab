function action_performed=frameSpecBufferInsert(theBlkPath,portIdx,frameSizeText)



    frameSize=str2double(frameSizeText);
    if~(isscalar(frameSize)&&isnumeric(frameSize)&&(frameSize>0)&&(fix(frameSize)==frameSize))
        error(message('dataflow:Multirate:InvalidPortSpec'));
    end

    parentPath=get_param(theBlkPath,'Parent');
    theBlk=theBlkPath(length(parentPath)+2:end);

    portData=get_param(theBlkPath,'PortConnectivity');
    if~isempty(portData(portIdx).SrcPort)

        srcName=get_param(portData(portIdx).SrcBlock,'Name');
        bufferPos=calcBufferPosition(...
        get_param([parentPath,'/',srcName],'position'),...
        get_param(theBlkPath,'position'),...
        get_param(theBlkPath,'orientation'));

        insertBufferName=['ADHInsertedtBufferAt',theBlk,'Port',num2str(portIdx)];
        insertBufferPath=[parentPath,'/',insertBufferName];
        add_block('built-in/Buffer',insertBufferPath);
        set_param(insertBufferPath,...
        'N',frameSizeText,...
        'orientation',get_param(theBlkPath,'orientation'),...
        'position',bufferPos,...
        'ShowName','off');


        lineHandles=get_param(theBlkPath,'LineHandles');
        delete_line(lineHandles.Inport(portIdx));


        srcPort=portData(portIdx).SrcPort+1;
        hSrc=get_param([parentPath,'/',srcName],'PortHandles');
        hSS=get_param(insertBufferPath,'PortHandles');
        hBlk=get_param(theBlkPath,'PortHandles');
        add_line(parentPath,hSS.Outport(1),hBlk.Inport(portIdx),...
        'AUTOROUTING','ON');
        add_line(parentPath,hSrc.Outport(srcPort),hSS.Inport(1),...
        'AUTOROUTING','ON');
    end

    action_performed=getString(message('dataflow:Multirate:PortDimsSpecifierApplied',frameSize));

end

function bufferPos=calcBufferPosition(srcPos,dstPos,dstOrientation)
    switch dstOrientation
    case 'right'
        dstEdge=dstPos(1);
        srcEdge=srcPos(3);
        dstWidth=dstPos(3)-dstPos(1);
        dstHeightCenter=round((dstPos(2)+dstPos(4))/2);
        bufferSize=min(round((dstEdge-srcEdge)/3),dstWidth);
        bufferPos=[(dstEdge-2*bufferSize),(dstHeightCenter-12),(dstEdge-bufferSize),(dstHeightCenter+12)];
    case 'up'
        srcEdge=srcPos(2);
        dstEdge=dstPos(4);
        dstWidth=dstPos(4)-dstPos(2);
        dstHeightCenter=round((dstPos(1)+dstPos(3))/2);
        bufferSize=min(round((srcEdge-dstEdge)/3),dstWidth);
        bufferPos=[(dstHeightCenter-12),(dstEdge+bufferSize),(dstHeightCenter+12),(dstEdge+2*bufferSize)];
    case 'left'
        dstEdge=dstPos(3);
        srcEdge=srcPos(1);
        dstWidth=dstPos(3)-dstPos(1);
        dstHeightCenter=round((dstPos(2)+dstPos(4))/2);
        bufferSize=min(round((srcEdge-dstEdge)/3),dstWidth);
        bufferPos=[(dstEdge+bufferSize),(dstHeightCenter-12),(dstEdge+2*bufferSize),(dstHeightCenter+12)];
    otherwise
        dstEdge=dstPos(2);
        srcEdge=srcPos(4);
        dstWidth=dstPos(4)-dstPos(2);
        dstHeightCenter=round((dstPos(1)+dstPos(3))/2);
        bufferSize=min(round((dstEdge-srcEdge)/3),dstWidth);
        bufferPos=[(dstHeightCenter-12),(dstEdge-2*bufferSize),(dstHeightCenter+12),(dstEdge-bufferSize)];
    end
end
