function portType=getActualSrcPortType(blk,portIdx)















    ports=get_param(blk,'Ports');

    hasDataPort=ports(1)>0;
    hasEnablePort=ports(3)>0;
    hasTriggerPort=ports(4)>0;
    hasIfactionPort=ports(8)>0;
    hasInvInput=hasInvisibleInput(blk);

    nIPorts=ports(1);
    nCPorts=ports(3)+ports(4)+ports(8);
    maxIdx=nIPorts+nCPorts+hasInvInput;

    if portIdx<1
        error('getActualSrcPortType:portidxlt1',...
        'Port index must be > 0')
    elseif maxIdx==0
        error('getActualSrcPortType:portidxnoinput',...
        'Block does not have inputs')
    elseif portIdx>maxIdx;
        error('getActualSrcPortType:portidxgtmax',...
        'Port index must be <= %d',maxIdx)
    end

    portType=[];

    if hasInvInput||(hasDataPort&&portIdx<=nIPorts)
        portType='DataPort';
    elseif hasEnablePort
        enablePortIdx=nIPorts+1;
        if portIdx==enablePortIdx
            portType='EnablePort';
        elseif hasTriggerPort
            triggerPortIdx=enablePortIdx+1;
            if portIdx==triggerPortIdx
                portType='TriggerPort';
            end
        end
    elseif hasTriggerPort
        triggerPortIdx=nIPorts+1;
        if portIdx==triggerPortIdx
            portType='TriggerPort';
        end
    elseif hasIfactionPort
        ifactionPortIdx=nIPorts+1;
        if portIdx==ifactionPortIdx
            portType='IfactionPort';
        end
    else
        error('Should not be here')
    end

end