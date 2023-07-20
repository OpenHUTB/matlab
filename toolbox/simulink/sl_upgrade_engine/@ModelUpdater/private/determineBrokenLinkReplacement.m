function replacementInfo=determineBrokenLinkReplacement(h,block)






    oldMaskType=strtrim(get_param(block,'MaskType'));
    replacementInfo.oldMaskType=oldMaskType;
    replacementInfo.newMaskType='';
    replacementInfo.newBlockType='';
    replacementInfo.newRefBlock='';
    replacementInfo.functionHandle=[];


    if~isempty(oldMaskType)
        ii=find(strcmp(oldMaskType,h.OldMaskTypeCell));
        if~isempty(ii)
            replacementInfo=getRefinedLinkMatch(h,block,h.MapOldMaskToCurrent(ii));
        end
    end

end
