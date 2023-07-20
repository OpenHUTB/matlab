function protectModel(cbinfo,action)





    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~(SLStudio.Utils.objectIsValidModelReferenceBlock(block)&&...
        cbinfo.domain.isBdInEditMode(cbinfo.model.handle)&&...
        SLStudio.Utils.objectIsValidUnprotectedModelReferenceBlock(block))
        action.enabled=false;
    else
        action.enabled=true;
    end

end
