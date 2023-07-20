function result=isCgirReducedBlock(obj,sid)


    result=false;
    if~isempty(obj.CgirReducedBlocks)
        result=obj.CgirReducedBlocks.isKey(sid);
    end
end
