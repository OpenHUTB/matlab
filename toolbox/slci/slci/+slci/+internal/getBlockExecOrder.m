



function out=getBlockExecOrder(blkHandles)

    out=[];
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    if numel(blkHandles)==1
        out=0;
        return;
    end
    startNode=getStartBlk(blkHandles);
    blkObj=arrayfun(@(x)get_param(x,'Object'),blkHandles);
    blkName=arrayfun(@(x)x.getRTWName,blkObj,'UniformOutput',false);

    originalIdx=(1:numel(blkHandles))-1;



    blkMap=containers.Map(blkName,originalIdx);
    blockOrder=getExecOrder(blkMap,startNode);
    if numel(blockOrder)==numel(blkHandles)
        out=zeros(1,numel(blockOrder));



        for i=1:numel(blockOrder)
            out(blockOrder(i)+1)=originalIdx(i);
        end
    end
end


function out=getStartBlk(blkHandles)
    out=[];
    visited=[];
    sourceBlkHandle=[];

    for i=1:numel(blkHandles)
        aHandle=blkHandles(i);
        sourceBlkHandle=[sourceBlkHandle,getSourceBlk(aHandle,'Trigger')];
    end

    sourceBlkHandle=unique(sourceBlkHandle);

    if numel(sourceBlkHandle)==1
        out=sourceBlkHandle;
        return;
    end



    toVisit=sourceBlkHandle;
    while numel(toVisit)>0
        aHandle=toVisit(1);
        srcBlkHandle=getSourceBlk(aHandle,'Inport');
        visited=[visited,aHandle];
        toVisit=toVisit(2:end);
        if(isempty(find(toVisit==srcBlkHandle)))...
            &&(isempty(find(visited==srcBlkHandle)))
            toVisit=[toVisit,srcBlkHandle];
        end

        if(numel(toVisit)==1)...
            &&((~strcmpi(get_param(toVisit,'BlockType'),'FunctionCallSplit')...
            ||(~strcmpi(get_param(toVisit,'BlockType'),'Demux'))))
            out=toVisit;
            break;
        end
    end
end


function out=getSourceBlk(aHandle,PortType)

    out=[];
    if strcmpi(PortType,'Trigger')
        blkPorts=get_param(aHandle,'PortHandles');
        port=blkPorts.Trigger;
    else
        blkPorts=get_param(aHandle,'PortHandles');
        port=blkPorts.Inport;
    end
    if isempty(port)
        return;
    end
    pObj=get_param(port,'Object');
    srcPort=pObj.getGraphicalSrc;
    sPort=get_param(srcPort,'Object');
    srcBlkHandle=get_param(sPort.Parent,'Handle');
    out=srcBlkHandle;

    if strcmpi(get_param(srcBlkHandle,'type'),'block')...
        &&strcmpi(get_param(srcBlkHandle,'blocktype'),'From')


        gotoBlks=get_param(srcBlkHandle,'GotoBlock');
        assert(isstruct(gotoBlks)&&isfield(gotoBlks,'handle'));
        out=getSourceBlk(gotoBlks.handle,'Inport');
    end

end


function out=getExecOrder(blkMap,startNode)
    startNodeObj=get_param(startNode,'Object');
    startNodeName=startNodeObj.getRTWName;

    if isKey(blkMap,startNodeName)
        out=blkMap(startNodeName);
        return;
    end



    execOrderList=[];
    dstBlks=getDestinationBlock(startNode);
    for i=1:numel(dstBlks)
        orderedBlks=getExecOrder(blkMap,dstBlks(i));
        for j=1:numel(orderedBlks)
            if~ismember(orderedBlks(j),execOrderList)
                execOrderList=[execOrderList,orderedBlks(j)];%#ok
                if(numel(execOrderList)==blkMap.length)
                    break;
                end
            end
        end
    end

    out=execOrderList;
end


function out=getDestinationBlock(blkHandle)
    out=[];
    outports=getOutPorts(blkHandle);
    dstBlks=[];
    for i=1:numel(outports)
        port=get_param(outports(i),'Object');
        dst=port.getGraphicalDst;
        dstPortObj=get_param(dst,'Object');
        if iscell(dstPortObj)
            for j=1:numel(dstPortObj)
                dstBlks=[dstBlks;get_param(dstPortObj{j}.Parent,'Handle')];%#ok
            end
        else
            dstBlks=[dstBlks,get_param(dstPortObj.Parent,'Handle')];%#ok
        end
    end

    for i=1:numel(dstBlks)
        blkH=dstBlks(i);
        if strcmpi(get_param(blkH,'type'),'block')...
            &&strcmpi(get_param(blkH,'blocktype'),'Goto')

            fromBlks=get_param(blkH,'FromBlocks');
            for j=1:numel(fromBlks)
                assert(isstruct(fromBlks(j))&&isfield(fromBlks(j),'handle'));
                out=[out,getDestinationBlock(fromBlks(j).handle)];%#ok
            end
        else
            out=[out,blkH];%#ok
        end
    end
end


function out=getOutPorts(aHandle)
    ports=get_param(aHandle,'PortHandles');
    out=ports.Outport;
end