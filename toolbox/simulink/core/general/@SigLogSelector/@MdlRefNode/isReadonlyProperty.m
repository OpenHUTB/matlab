function bReadOnly=isReadonlyProperty(h,propName)




    bReadOnly=false;
    if~h.isValidProperty(propName)
        return;
    end

    mi=h.getModelLoggingInfo();
    bReadOnly=...
    (mi.OverrideMode~=...
    Simulink.SimulationData.LoggingOverrideMode.OverrideSomeRefs);

end

