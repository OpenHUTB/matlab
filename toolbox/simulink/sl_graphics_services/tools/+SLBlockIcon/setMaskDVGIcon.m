function setMaskDVGIcon(blk,iconKey)








    maskObj=Simulink.Mask.get(blk);
    if isempty(maskObj)
        maskObj=Simulink.Mask.create(blk);
    end
    try
        maskObj.BlockDVGIcon=iconKey;
    catch ex
        maskObj=Simulink.Mask.create(blk);
        maskObj.BlockDVGIcon=iconKey;
    end
end