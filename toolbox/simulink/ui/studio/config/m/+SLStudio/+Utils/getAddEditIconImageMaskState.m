function state=getAddEditIconImageMaskState(cbinfo)



    state='Disabled';
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(block)
        return;
    end

    if(strcmpi(SLStudio.Utils.getAddEditMaskState(cbinfo),'Disabled')||...
        SLStudio.Utils.isMaskReadOnly(cbinfo))
        return;
    end

    [maskObj,canApplyNewMask]=Simulink.Mask.get(block.handle);
    if canApplyNewMask
        state='Enabled';
        return;
    end

    [simpleImageMask,emptyDisplay]=Simulink.Mask.isSimpleImageMask(maskObj);
    if emptyDisplay||simpleImageMask
        state='Enabled';
        return;
    end
end
