function addTraceability(m2mObj,aOriBlk,aNewBlk)



    newBlk=[m2mObj.fPrefix,aNewBlk];
    if isKey(m2mObj.fTraceabilityMap,newBlk)
        m2mObj.fTraceabilityMap(newBlk)=[m2mObj.fTraceabilityMap(newBlk),aOriBlk];
    else
        m2mObj.fTraceabilityMap(newBlk)={aOriBlk};
    end

    if isKey(m2mObj.fTraceabilityMap,aOriBlk)
        m2mObj.fTraceabilityMap(aOriBlk)=[m2mObj.fTraceabilityMap(aOriBlk),newBlk];
    else
        m2mObj.fTraceabilityMap(aOriBlk)={newBlk};
    end
end
