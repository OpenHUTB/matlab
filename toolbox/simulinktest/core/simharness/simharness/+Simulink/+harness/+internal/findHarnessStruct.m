function[systemModel,harnessStruct]=findHarnessStruct(harnessOwner,harnessName)
    [systemModel,harnessOwnerHandle]=Simulink.harness.internal.parseForSystemModel(harnessOwner);
    Simulink.harness.internal.validateOwnerHandle(systemModel,harnessOwnerHandle);
    harnessStruct=Simulink.harness.internal.validateHarnessNameForOwner(systemModel,harnessOwnerHandle,harnessName);
end
