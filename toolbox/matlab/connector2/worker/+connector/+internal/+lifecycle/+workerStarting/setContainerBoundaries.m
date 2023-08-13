function setContainerBoundaries()
    persistent isCallbackRegistered;

    connector.internal.updateContainerBoundaryPreferences();


    if isempty(isCallbackRegistered)
        matlab.prefdir.internal.regCallbackPrefdirUpdated(@connector.internal.updateContainerBoundaryPreferences);
        isCallbackRegistered=true;
        mlock;
    end
end
