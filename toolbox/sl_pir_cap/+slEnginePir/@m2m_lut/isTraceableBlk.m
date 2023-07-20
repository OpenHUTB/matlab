function isTraceable=isTraceableBlk(m2mObj,aHandle)



    isTraceable=0;
    blk=getfullname(aHandle);
    if isKey(m2mObj.fTraceabilityMap,blk)
        foundPrefix=strfind(blk,m2mObj.fPrefix);
        if isempty(foundPrefix)||foundPrefix>1
            isTraceable=1;
        else
            isTraceable=2;
        end
    end
end
