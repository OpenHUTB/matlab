function undoRefactorRefresher(cbinfo,action)

    cloneDetectionUIObj=get_param(cbinfo.model.Handle,'CloneDetectionUIObj');
    if isempty(cloneDetectionUIObj)
        action.enabled=false;
    else
        action.enabled=cloneDetectionUIObj.compareModelButtonEnable;
    end

end
