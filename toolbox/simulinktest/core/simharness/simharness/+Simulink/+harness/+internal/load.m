function load(harnessOwner,harnessName,licenseCheckout)



    try
        [systemModel,harnessStruct]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);
    catch ME
        ME.throwAsCaller();
    end


    if~(harnessStruct.canBeOpened)



        if(harnessStruct.isOpen==true)
            return;
        else

            activeHarness=Simulink.harness.internal.getHarnessList(systemModel,'active');
            if~isempty(activeHarness)
                DAStudio.error('Simulink:Harness:AnotherHarnessAlreadyActivated',...
                harnessName,activeHarness.name,activeHarness.model);
            end
        end
    end

    if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
        Simulink.harness.internal.loadBDHarness(systemModel,harnessStruct.name,licenseCheckout);
    else
        Simulink.harness.internal.loadHarness(systemModel,harnessStruct.name,harnessStruct.ownerHandle,licenseCheckout);
    end


    for dlg=DAStudio.ToolRoot.getOpenDialogs()'
        if strcmp(dlg.dialogTag,'CreateSimulationHarnessDialog')
            src=dlg.getSource();
            if strcmp(bdroot(src.harnessOwner.getFullName()),systemModel)
                delete(dlg);
            end
        end
    end

    if harnessStruct.rebuildOnOpen

        Simulink.harness.internal.rebuild(harnessStruct.ownerHandle,harnessStruct.name);
    end
end
