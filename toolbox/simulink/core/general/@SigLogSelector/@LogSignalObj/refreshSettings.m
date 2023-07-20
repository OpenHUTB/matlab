function refreshSettings(h)





    bpath=h.signalInfo.blockPath_;
    portIdx=h.signalInfo.outputPortIndex_;
    mi=h.hParent.getModelLoggingInfo;
    [bDef,h.signalInfo,sigIdx]=mi.getSettingsForSignal(...
    bpath,...
    portIdx,...
    bpath.SubPath,...
    false,...
    '',...
    false);


    if isempty(h.signalInfo)
        h.signalInfo=Simulink.SimulationData.SignalLoggingInfo;
        h.signalInfo.blockPath_=bpath;
        h.signalInfo.outputPortIndex_=portIdx;
        h.signalInfo=h.signalInfo.updateSettingsFromPort;
        if~bDef
            h.signalInfo.loggingInfo_.DataLogging=false;
        end
    else



        me=SigLogSelector.getExplorer;
        me.isSettingDataLoggingOveride=true;
        h.signalInfo=mi.updateSignalNameCache(sigIdx);
        me.isSettingDataLoggingOveride=false;
    end


    h.Name=h.signalInfo.getSignalNameFromPort(...
    true,...
    true);


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ReadonlyChangedEvent',h);
    h.firePropertyChange;

end
