function existBlk=searchPairs2Blk(blk,searchPairSets)



    existBlk=[];

    for i=1:length(searchPairSets)
        existBlk=find(blk,searchPairSets{i});
        if~isempty(existBlk)
            break;
        end
    end
end