function res=isTestbenchTask(modelName,taskName)




    import soc.internal.connectivity.*

    res=false;
    taskMgr=getTaskManagerBlock(modelName,'overrideAssert');
    outPorts=getSystemOutputPorts(taskMgr);
    for i=1:numel(outPorts)
        portHdl=get_param(outPorts{i},'Handle');
        if~isequal(get_param(portHdl,'Name'),taskName),continue;end
        res=loc_getModelConnectedToTaskManagerPort(portHdl);
    end
end


function res=loc_getModelConnectedToTaskManagerPort(blkh)
    while(~isempty(blkh)&&~isequal(get_param(blkh,'BlockType'),...
        'ModelReference'))
        [res,blkh]=loc_isConnectedToTestbenchTask(blkh);
    end
end


function[res,out]=loc_isConnectedToTestbenchTask(blkh)
    import soc.internal.connectivity.*
    res=false;
    switch(get_param(blkh,'BlockType'))
    case 'Inport'
        hPort=get_param(blkh,'PortConnectivity');
        dstBlkHdl=hPort.DstBlock;
        dstType=get_param(hPort.DstBlock,'BlockType');
        switch(dstType)
        case{'Outport','ModelReference'}
            out=dstBlkHdl;
        case 'SubSystem'
            ports=getSystemInputPorts(hPort.DstBlock);
            idx=arrayfun(@(x)(isequal(get_param(x,'Port'),...
            num2str(hPort.DstPort+1))),ports);
            out=ports(idx);
        otherwise
            assert(false,'verifyTaskManagerConnections must catch this');
        end
    case 'Outport'
        parent=get_param(blkh,'Parent');
        portNum=get_param(blkh,'Port');
        allPorts=get_param(parent,'PortConnectivity');
        idx=arrayfun(@(x)(~isempty(x.DstBlock)&&...
        isequal(x.Type,portNum)),allPorts);
        if~any(idx)
            assert(false,'verifyTaskManagerConnections must catch this');
        end
        hPort=allPorts(idx);
        if isempty(hPort.DstBlock)
            out=[];
        elseif isequal(get_param(hPort.DstBlock,'MaskType'),'TestbenchTask')
            res=true;
            out=[];
        elseif isequal(get_param(hPort.DstBlock,'BlockType'),'SubSystem')
            inpPorts=getSystemInputPorts(hPort.DstBlock);
            trigPort=getSystemTriggerPort(hPort.DstBlock);
            if~isempty(trigPort)
                out=[];
            else
                idx=arrayfun(@(x)(isequal(get_param(x,'Port'),...
                num2str(hPort.DstPort+1))),inpPorts);
                out=inpPorts(idx);
            end
        elseif isequal(get_param(hPort.DstBlock,'BlockType'),'ModelReference')
            out=hPort.DstBlock;
        elseif isequal(get_param(hPort.DstBlock,'BlockType'),'Outport')
            out=hPort.DstBlock;
        else
            assert(false,'verifyTaskManagerConnections must catch this');
        end
    otherwise
        assert(false,'verifyTaskManagerConnections must catch this');
    end
end