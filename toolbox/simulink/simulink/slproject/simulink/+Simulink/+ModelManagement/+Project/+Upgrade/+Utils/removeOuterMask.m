function removeOuterMask(topLevelSystem,baseSystem)






    maskObj=Simulink.Mask.get(topLevelSystem);
    hasOnlyBaseMask=~isempty(Simulink.Mask.get(baseSystem))&&isempty(maskObj.BaseMask);
    if~isempty(maskObj)&&~hasOnlyBaseMask
        maskObj.delete;
    end

end

