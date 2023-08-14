function out=getBlockReductionReasons(h)



    if~h.ReductionReasonIsCached
        h.cacheBlockReductionReasons();
    end
    out=h.BlockReductionReasons;

end

