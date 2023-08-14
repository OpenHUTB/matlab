function setOverrideMode(h,val)





    mi=h.getModelLoggingInfo;


    switch val
    case 0
        mi.OverrideMode=...
        Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel;
    otherwise
        mi.OverrideMode=...
        Simulink.SimulationData.LoggingOverrideMode.OverrideSomeRefs;
    end





    if~h.containsModelReference
        mi=mi.setLogAsSpecifiedInModel(h.Name,val==0);
    end


    h.setModelLoggingInfo(mi);


    h.firePropertyChange;
    h.refreshSignals;

end

