function push(harnessOwner,harnessName)





    try
        [systemModel,harness]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);
        systemH=get_param(systemModel,'Handle');
        if bdIsLibrary(systemModel)||bdIsSubsystem(systemModel)
            DAStudio.error('Simulink:Harness:CannotPushLibHarness');
        end

        if Simulink.internal.isArchitectureModel(systemModel)

            DAStudio.error('Simulink:Harness:CannotPushZCHarness');
        end
    catch ME
        throwAsCaller(ME);
    end

    activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);
    if~isempty(activeHarness)
        if~(strcmp(activeHarness.name,harness.name)&&...
            strcmp(activeHarness.ownerFullPath,harness.ownerFullPath))
            errId='Simulink:Harness:CannotPushHarnessWhenAnotherHarnessIsActive';
            ME=MException(errId,'%s',...
            DAStudio.message(errId,harness.name,harness.ownerFullPath,activeHarness.name,activeHarness.ownerFullPath));
            throwAsCaller(ME);
        end
    end



    try
        Simulink.harness.internal.checkHarnessOwner(systemH,harness.name,harness.ownerHandle);
    catch ME
        throwAsCaller(ME);
    end

    try
        Simulink.harness.internal.pushHarness(systemH,harness.name,harness.ownerHandle);
    catch ME
        throwAsCaller(ME);
    end

end

