function[srcPortList,dstPortList,srcBlkList,dstBlkList]=getSrcDstList(currentBlock,deleteLines)

    if nargin<2
        deleteLines=true;
    end

    blkPortHdls=get_param(currentBlock,'PortHandles');
    currentBlkHandle=get_param(currentBlock,'Handle');
    portTypes=fields(blkPortHdls);

    srcPortList=[];
    dstPortList=[];
    srcBlkList=[];
    dstBlkList=[];

    for k=1:length(portTypes)
        portHandle=blkPortHdls.(portTypes{k});
        for j=1:length(portHandle)
            [blockPortHandles,blockHandles,isaSource]=Simulink.SimplifyModel.getPortConnections(portHandle(j),deleteLines);
            [srcBlkList,dstBlkList]=getCompList(blockHandles,currentBlkHandle,isaSource,srcBlkList,dstBlkList);
            [srcPortList,dstPortList]=getCompList(blockPortHandles,portHandle(j),isaSource,srcPortList,dstPortList);
        end
    end

    function[srcList,dstList]=getCompList(handlesList,currentHandle,isaSource,srcList,dstList)
        for i=1:length(handlesList)
            if handlesList(i)~=-1&&handlesList(i)~=currentHandle
                if isaSource&&~any(handlesList(i)==srcList)
                    srcList(end+1)=handlesList(i);%#ok<*AGROW>
                elseif~isaSource&&~any(handlesList(i)==dstList)
                    dstList(end+1)=handlesList(i);
                end
            end
        end
