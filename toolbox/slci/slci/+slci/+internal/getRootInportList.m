function blkHandles=getRootInportList(sys)




    blkHandles=find_system(sys,'SearchDepth',1,'BlockType','Inport');
    if slcifeature('BEPSupport')==0&&slcifeature('VirtualBusSupport')==1


        blkHandles=updateBusTypeInportHandles(blkHandles);
    end
end

function out=updateBusTypeInportHandles(blkHandles)





    delIndices=[];




    newBlkHandles=[];
    for i=1:numel(blkHandles)
        aBlkHandle=blkHandles(i);
        portHandles=get_param(aBlkHandle,'PortHandles');
        compiledBusType=get_param(portHandles.Outport,'CompiledBusType');
        if(strcmp(compiledBusType,'VIRTUAL_BUS'))
            delIndices(end+1)=i;
            actDest=slci.internal.getActualDst(aBlkHandle,0);
            for k=1:size(actDest,1)
                dstBlkHandle=actDest(k,1);
                port=actDest(k,2);
                actSrc=slci.internal.getActualSrc(dstBlkHandle,port);
                actBlkHandle=actSrc(1,1);
                newBlkHandles(end+1)=actBlkHandle;
            end
        end
    end
    out=blkHandles;
    if~isempty(delIndices)
        out(delIndices)=[];
        out=[out,newBlkHandles];
    end
end

