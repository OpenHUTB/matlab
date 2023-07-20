






function result=misraIsJustifiedCorrectly(justification,guideline)
    result=false;
    if isempty(justification)
        return;
    end
    if~strcmp(justification.type,'MISRA-C3')
        return;
    end
    guidelineList=strsplit(justification.guidelines,',');
    for index=1:numel(guidelineList)
        thisGuideline=strtrim(guidelineList{index});
        if strcmp(thisGuideline,guideline)
            result=true;
            break;
        end
    end
end

