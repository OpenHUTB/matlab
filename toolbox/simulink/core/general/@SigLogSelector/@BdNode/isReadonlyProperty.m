function bReadOnly=isReadonlyProperty(h,~)




    mi=h.getModelLoggingInfo();
    bReadOnly=...
    (mi.OverrideMode~=...
    Simulink.SimulationData.LoggingOverrideMode.OverrideSomeRefs);

end

