function close(harnessOwner,harnessName)

    try
        [systemModel,harnessStruct]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);
    catch ME
        ME.throwAsCaller();
    end
    if~harnessStruct.isOpen

        DAStudio.error('Simulink:Harness:CannotDeactivateInactiveHarness',harnessStruct.name);
    end

    if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
        Simulink.harness.internal.closeBDHarness(systemModel,harnessStruct.name,false);
    else
        Simulink.harness.internal.closeHarness(systemModel,harnessStruct.name,harnessStruct.ownerHandle,false);
    end



    Simulink.harness.internal.refreshHarnessToolstrip(systemModel);
end
