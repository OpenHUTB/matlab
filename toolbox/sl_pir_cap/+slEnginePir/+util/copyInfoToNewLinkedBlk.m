function copyInfoToNewLinkedBlk(aNewBlk,aOriBlk)




    infoToCopy={'position','linkdata'};
    for iIdx=1:length(infoToCopy)
        info=get_param(aOriBlk,infoToCopy{iIdx});
        set_param(aNewBlk,infoToCopy{iIdx},info);
    end


    maskObj=Simulink.Mask.get(aOriBlk);
    if~isempty(maskObj)
        set_param(aNewBlk,'linkstatus','inactive');
        copiedMaskObj=Simulink.Mask.get(aNewBlk);
        copiedMaskObj.copy(maskObj);
        set_param(aNewBlk,'linkstatus','restore');
    end
end


