function enableEventCallback(evtName)
    apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();
    apiObj.setEventCallbackState(evtName,true);
end
