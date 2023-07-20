function checkMdlRefandFcnPlatform(cbinfo,action)





    coder.internal.toolstrip.refresher.checkMdlRef(cbinfo,action);
    isFcnPlatform=coder.internal.toolstrip.util.getPlatformType(cbinfo.model.handle);
    if isFcnPlatform
        action.enabled=false;
    end

