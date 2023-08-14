function res=isProxyTask(modelName,taskName)




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
    res=false;
    dstPort=0;
    while~isempty(blkh)
        [res,blkh,dstPort]=loc_isConnectedToProxyTask(blkh,dstPort);
    end
end


function[res,out,dstPort]=loc_isConnectedToProxyTask(blkh,dstPort)
    import soc.internal.connectivity.*
    res=false;
    switch(get_param(blkh,'BlockType'))
    case 'ModelReference'
        ports=getSystemInputPorts(get_param(blkh,'ModelName'));
        for i=1:numel(ports)
            b=ports{i};
            if~isequal(get_param(b,'BlockType'),'Inport')||...
                ~isequal(get_param(b,'OutputFunctionCall'),'on')||...
                ~isequal(dstPort,str2double(get_param(b,'Port')))
                continue;
            else
                out=get_param(b,'Handle');
            end
        end
    case 'AsynchronousTaskSpecification'
        ports=get_param(blkh,'PortConnectivity');
        idx=arrayfun(@(x)(~isempty(x.DstBlock)),ports);
        out=ports(idx).DstBlock;
        dstPort=1;
    case 'Inport'
        hPort=get_param(blkh,'PortConnectivity');
        dstBlkHdl=hPort.DstBlock;
        dstType=get_param(hPort.DstBlock,'BlockType');
        switch(dstType)
        case{'Outport','ModelReference'}
            out=dstBlkHdl;
        case 'SubSystem'
            subs=[get_param(dstBlkHdl,'Parent'),'/',get_param(dstBlkHdl,'Name')];
            ports=getSystemInputPorts(subs);
            idx=cellfun(@(x)(isequal(get_param(x,'Port'),...
            num2str(hPort.DstPort+1))),ports);
            out=ports{idx};
        case 'AsynchronousTaskSpecification'
            out=dstBlkHdl;
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
        elseif isequal(get_param(hPort.DstBlock,'MaskType'),'ProxyTask')
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
            dstPort=hPort.DstPort+1;
        elseif isequal(get_param(hPort.DstBlock,'BlockType'),'Outport')
            out=hPort.DstBlock;
        else
            assert(false,'verifyTaskManagerConnections must catch this');
        end
    case 'SubSystem'
        if isequal(get_param(blkh,'MaskType'),'ProxyTask')
            res=true;
            out=[];
        elseif isequal(get_param(blkh,'MaskType'),'TestbenchTask')
            res=false;
            out=[];
        else
            ports=getSystemInputPorts(blkh);
            for i=1:numel(ports)
                b=ports(i);
                if isequal(get_param(b,'BlockType'),'Inport')&&...
                    isequal(dstPort,str2double(get_param(b,'Port')))
                    pc=get_param(b,'PortConnectivity');
                    out=pc.DstBlock;
                    break
                end
            end
        end
    otherwise
        assert(false,'verifyTaskManagerConnections must catch this');
    end
end