function out=getOrigRootToSyntRootIOBlockMap(blkHandles)







    out=containers.Map('KeyType','double','ValueType','any');

    for i=1:numel(blkHandles)

        aBlkHandle=blkHandles(i);
        blkType=get_param(aBlkHandle,'BlockType');
        isInport=false;
        if strcmp(blkType,'Inport')
            isInport=true;
        elseif~strcmp(blkType,'Outport')
            continue;
        end
        isBEP=strcmp(get_param(aBlkHandle,'isComposite'),'on');
        if isBEP
            syntBlkHdls=slInternal('busDiagnostics','getCompiledBEPRootPortFromGrBEPBlock',aBlkHandle);
            if isInport
                out(aBlkHandle)=getSynthesizedInPorts(syntBlkHdls);
            else

                out(aBlkHandle)=getSynthesizedOutPorts(syntBlkHdls);
            end
        else
            portHandles=get_param(aBlkHandle,'PortHandles');
            if isInport
                compiledBusType=get_param(portHandles.Outport,'CompiledBusType');
                if(strcmp(compiledBusType,'VIRTUAL_BUS'))
                    out(aBlkHandle)=getSynthesizedInPorts(aBlkHandle);
                end
            else

                compiledBusType=get_param(portHandles.Inport,'CompiledBusType');
                if(strcmp(compiledBusType,'VIRTUAL_BUS'))
                    out(aBlkHandle)=getSynthesizedOutPorts(aBlkHandle);
                end
            end
        end
    end
end

function out=getSynthesizedInPorts(blkHdls)


    out=[];
    for i=1:numel(blkHdls)
        origBlkHdl=blkHdls(i);
        connectedBlk=slci.internal.getActualDst(origBlkHdl,0);
        for k=1:size(connectedBlk,1)
            connectedBlkHandle=connectedBlk(k,1);
            port=connectedBlk(k,2);
            actBlk=slci.internal.getActualSrc(connectedBlkHandle,port);
            actBlkHandle=actBlk(1,1);
            out(end+1)=actBlkHandle;
        end
    end
end

function out=getSynthesizedOutPorts(blkHdls)


    out=[];
    for i=1:numel(blkHdls)
        origBlkHdl=blkHdls(i);
        connectedBlk=slci.internal.getActualSrc(origBlkHdl,0);
        for k=1:size(connectedBlk,1)
            connectedBlkHandle=connectedBlk(k,1);
            port=connectedBlk(k,2);
            actBlk=slci.internal.getActualDst(connectedBlkHandle,port);
            actBlkHandle=actBlk(1,1);
            out(end+1)=actBlkHandle;
        end
    end
end