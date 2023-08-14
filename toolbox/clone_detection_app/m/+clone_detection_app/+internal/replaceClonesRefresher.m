function replaceClonesRefresher(cbinfo,action)

    cloneDetectionUIObj=get_param(cbinfo.model.Handle,'CloneDetectionUIObj');
    action.enabled=cloneDetectionUIObj.refactorButtonEnable;

end

