function[cstmIPBlks,internalCstmIPBlks]=findAllCustomIPBlks(modelName)




    cstmIPBlks={};
    internalCstmIPBlks={};

    if isempty(modelName)
        return;
    end

    if~iscell(modelName),modelName={modelName};end

    for i=1:numel(modelName)
        blks=libinfo(modelName{i},'searchdepth',1);
        for j=1:numel(blks)
            [isCstmIP,internalCstmIPBlk]=soc.internal.isSoCBCustomIPBlk(blks(j).Block);
            if isCstmIP
                cstmIPBlks{end+1}=blks(j).Block;%#ok<AGROW> 
                internalCstmIPBlks{end+1}=internalCstmIPBlk;%#ok<AGROW> 
            end
        end
    end
end