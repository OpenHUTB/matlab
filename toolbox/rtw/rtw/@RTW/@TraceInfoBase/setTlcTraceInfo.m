function setTlcTraceInfo(h,timestamp,reducedBlocks,insertedBlocks)



    h.setTimeStamp(timestamp);
    if~isempty(reducedBlocks)
        h.ReducedBlocks=reducedBlocks;
    end
    if~isempty(insertedBlocks)
        h.InsertedBlocks=insertedBlocks;
    end
