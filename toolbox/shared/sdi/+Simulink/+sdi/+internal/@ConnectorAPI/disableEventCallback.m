function disableEventCallback(evtName)
    apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();
    apiObj.setEventCallbackState(evtName,false);
end
