function name=getFullNameFromInstanceParameter(shortName,blockPath)














    name=shortName;
    if blockPath.getLength>0
        aPath=split(blockPath.getBlock(1),'/');

        assert(numel(aPath)>1);


        aPrefix=join(aPath(2:end),'_');
        name=[aPrefix{1},'_',name];
    end
