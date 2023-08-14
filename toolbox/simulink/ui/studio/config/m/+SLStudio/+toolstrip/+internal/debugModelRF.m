function debugModelRF(cbinfo,action)
    model=cbinfo.model;
    if isempty(model),return;end

    action.enabled=SLStudio.toolstrip.internal.getDebugModelState(cbinfo);
end