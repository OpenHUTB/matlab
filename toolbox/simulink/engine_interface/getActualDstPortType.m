function portType=getActualDstPortType(blk,portIdx)















    ports=get_param(blk,'Ports');

    hasDataPort=ports(2)>0;
    hasStatePort=ports(5)>0;
    hasInvOutput=hasInvisibleOutput(blk);

    nOPorts=ports(2);
    nSPorts=ports(5);
    maxIdx=nOPorts+nSPorts+hasInvOutput;

    if portIdx<1
        error('getActualDstPortType:portidxlt1',...
        'Port index must be > 0')
    elseif maxIdx==0
        error('getActualDstPortType:portidxnoinput',...
        'Block does not have outputs')
    elseif portIdx>maxIdx;
        error('getActualDstPortType:portidxgtmax',...
        'Port index must be <= %d',maxIdx)
    end

    portType=[];

    if hasInvOutput||(hasDataPort&&portIdx<=nOPorts)
        portType='DataPort';
    elseif hasStatePort
        statePortIdx=nOPorts+1;
        if portIdx==statePortIdx
            portType='StatePort';
        end
    else
        error('should not be here')
    end

end