function debugModelCB(cbinfo)
    model=cbinfo.model;
    if isempty(model),return;end

    sldebugui('Create',model.Name);
end