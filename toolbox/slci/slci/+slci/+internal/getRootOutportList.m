


function blkHandles=getRootOutportList(sys)

    blkHandles=[];
    if isSysBlockDiagram(sys)
        blkHandles=find_system(sys,'SearchDepth',1,'BlockType','Outport');
        if slcifeature('BEPSupport')==0&&slcifeature('VirtualBusSupport')==1


            blkHandles=updateBusTypeOutportHandles(blkHandles);
        end
    end
end


function tf=isSysBlockDiagram(sys)
    sysType=get_param(sys,'Type');
    tf=strcmpi(sysType,'block_diagram');
end

function out=updateBusTypeOutportHandles(blkHandles)





    delIndices=[];




    newBlkHandles=[];
    for i=1:numel(blkHandles)
        aBlkHandle=blkHandles(i);
        portHandles=get_param(aBlkHandle,'PortHandles');
        compiledBusType=get_param(portHandles.Inport,'CompiledBusType');
        if(strcmp(compiledBusType,'VIRTUAL_BUS'))
            delIndices(end+1)=i;
            actSrc=slci.internal.getActualSrc(aBlkHandle,0);
            for k=1:size(actSrc,1)
                dstBlkHandle=actSrc(k,1);
                port=actSrc(k,2);
                actDst=slci.internal.getActualDst(dstBlkHandle,port);
                actBlkHandle=actDst(1,1);
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
