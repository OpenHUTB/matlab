function SaveRefModelsRF(cbinfo,action)
    if(SLStudio.toolstrip.internal.haveDirtyRefModels(cbinfo)||~isempty(slInternal('getAllDirtySSRefBDs',cbinfo.model.Handle)))
        action.enabled=true;
    else
        action.enabled=false;
    end
end
