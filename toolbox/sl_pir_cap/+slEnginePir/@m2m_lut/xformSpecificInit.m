function errMsg=xformSpecificInit(m2mObj)


    m2mObj.fTraceabilityMap=containers.Map('KeyType','char','ValueType','any');
    m2mObj.fPosRefCount=containers.Map('KeyType','char','ValueType','double');

    for gIdx=1:length(m2mObj.fCandidates)
        numXformedPorts=length(m2mObj.fCandidates(gIdx).LutPorts);
        xformedBlks=[];
        for bIdx=1:length(m2mObj.fCandidates(gIdx).LutPorts)
            blk=m2mObj.fCandidates(gIdx).LutPorts(bIdx).Block;
            if m2mObj.isExcludedBlk(blk)
                numXformedPorts=numXformedPorts-1;
            else
                if~m2mObj.isInvalidBlk(blk)
                    xformedBlks=[xformedBlks,{blk}];
                end
            end
        end
        if numXformedPorts>1
            m2mObj.fXformedBlks=[m2mObj.fXformedBlks,xformedBlks];
        end
    end
    m2mObj.fXformedBlks=unique(m2mObj.fXformedBlks);

    m2mObj.getXformedModels;
    errMsg=[];
end
