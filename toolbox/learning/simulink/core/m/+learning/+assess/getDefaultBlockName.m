function defaultBlockName=getDefaultBlockName(blockType)
    defaultBlockName=blockType;
    nameList=slprivate('blockTypeToDefaultNames');
    matchRow=cellfun(@(x)isequal(x,blockType),nameList(:,1));
    if any(matchRow)
        matchCell=nameList(matchRow,:);
        blockName=char(matchCell{2});


        defaultBlockName=strtrim(blockName(1,:));
    end
end