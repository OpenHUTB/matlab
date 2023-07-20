function out=getTypeOptions(paramName,blockName)













    blockList=find_system(blockName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
    numBlock=numel(blockList);
    newBlockList=[];

    idxNew=1;
    for idx=1:numBlock
        thisBlock=blockList{idx};
        str=get_param(thisBlock,'ObjectParameters');
        if isfield(str,paramName)
            tempStr=strrep(thisBlock,gcb,'');
            tempStr=strcat(tempStr,'/',paramName);
            newBlockList{idxNew}=tempStr(2:end);
            idxNew=idxNew+1;
        end
    end

    if~isempty(newBlockList)
        typeOptions=newBlockList;
    else
        typeOptions=[];
    end

    out=typeOptions;
end
