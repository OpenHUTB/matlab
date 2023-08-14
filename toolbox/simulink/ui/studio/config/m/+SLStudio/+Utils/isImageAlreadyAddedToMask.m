function state=isImageAlreadyAddedToMask(cbinfo)



    state=true;
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(block)
        return;
    end
    [maskObj,canApplyNewMask]=Simulink.Mask.get(block.handle);

    if canApplyNewMask
        state=false;
        return;
    end

    if isempty(maskObj.Display)
        state=false;
    end
end
