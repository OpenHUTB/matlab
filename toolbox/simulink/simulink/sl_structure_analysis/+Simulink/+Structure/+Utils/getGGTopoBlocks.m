







function hGGTopoBlocks=getGGTopoBlocks(hCompTopoBlocks)
    if isempty(hCompTopoBlocks)
        hGGTopoBlocks=[];
        return;
    end
    CompTopoBlocksObj=get(hCompTopoBlocks,'object');
    if length(CompTopoBlocksObj)==1
        CompTopoBlocksObj={CompTopoBlocksObj};
    end

    hGGTopoBlocks=cellfun(@(obj)obj.getTrueOriginalBlock,CompTopoBlocksObj);

end