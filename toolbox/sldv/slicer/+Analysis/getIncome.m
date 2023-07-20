function[blkH,portId]=getIncome(bh,outcomeIdx)



    switch outcomeIdx
    case 1
        portId=3;
    case 2
        portId=1;
    otherwise
        error('Unknown option');
    end
    ph=get(bh,'PortHandles');
    outPort=get(ph.Inport(portId),'Object');

    controlPort=outPort.getActualSrc;
    if~isempty(controlPort)
        blkH=get(controlPort(1),'ParentHandle');
    else
        blkH=[];
    end


end