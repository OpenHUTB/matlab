function[blkh,blkType]=getModelConnectedToTaskManagerPort(blkh)





    stopSearch=false;
    while(~stopSearch)
        [blkh,stopSearch,blkType]=loc_getdownstreamblock(blkh);
    end
end


function[dstBlk,stopSearch,dstBlkType]=loc_getdownstreamblock(thisBlk)
    import soc.internal.connectivity.*
    switch(get_param(thisBlk,'BlockType'))
    case 'Inport'
        thisPort=get_param(thisBlk,'PortConnectivity');
        dstBlk=thisPort.DstBlock;
        dstBlkType=get_param(dstBlk,'BlockType');
        switch(dstBlkType)
        case 'Outport'
            stopSearch=false;
        case 'SubSystem'
            if~isempty(getSystemTriggerPort(dstBlk))
                stopSearch=true;
            else
                inpPorts=getSystemInputPorts(dstBlk);
                idx=arrayfun(@(x)(isequal(get_param(x,'Port'),...
                num2str(thisPort.DstPort+1))),inpPorts);
                dstBlk=inpPorts(idx);
                stopSearch=false;
            end
        otherwise
            stopSearch=true;
        end
    case 'Outport'
        pNum=get_param(thisBlk,'Port');
        allPorts=get_param(get_param(thisBlk,'Parent'),'PortConnectivity');
        idx=arrayfun(@(x)(~isempty(x.DstBlock)&&isequal(x.Type,pNum)),allPorts);
        if~any(idx)
            dstBlk=[];
            stopSearch=true;
            dstBlkType='';
            return;
        else
            thisPort=allPorts(idx);
            dstBlk=thisPort.DstBlock;
            dstBlkType=get_param(dstBlk,'BlockType');
            if iscell(dstBlkType)
                stopSearch=true;
            elseif isequal(dstBlkType,'Outport')
                stopSearch=false;
            elseif isequal(dstBlkType,'SubSystem')
                if~isempty(getSystemTriggerPort(dstBlk))
                    stopSearch=true;
                else
                    inpPorts=getSystemInputPorts(dstBlk);
                    idx=arrayfun(@(x)(isequal(get_param(x,'Port'),...
                    num2str(thisPort.DstPort+1))),inpPorts);
                    dstBlk=inpPorts(idx);
                    stopSearch=false;
                end
            else
                stopSearch=true;
            end
        end
    otherwise
        assert(false,'Unhandled');
    end
end