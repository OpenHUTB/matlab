

function refreshSaveAsArchitectureTool(cbinfo,action)

    if isvalid(action)
        block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
        if(SLStudio.Utils.objectIsValidBlock(block))
            enabled=systemcomposer.internal.validator.ConversionUIValidator.canSaveAsArchitecture(block.handle);
        else
            enabled=false;
        end
        action.enabled=enabled;
    end
end
