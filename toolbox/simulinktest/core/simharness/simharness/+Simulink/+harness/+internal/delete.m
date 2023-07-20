function delete(harnessOwner,harnessName)

    try
        [systemModel,harnessStruct]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);
    catch ME
        ME.throwAsCaller();
    end

    activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);


    if harnessStruct.isOpen
        DAStudio.error('Simulink:Harness:CannotDeleteWhenHarnessIsOpen',harnessName);
    end


    if harnessStruct.canBeOpened==false&&~isempty(activeHarness)...
        &&activeHarness.ownerHandle~=harnessStruct.ownerHandle
        DAStudio.error('Simulink:Harness:CannotDeleteWhenATestingHarnessIsActive',harnessName);
    end


    if harnessStruct.canBeOpened==false&&harnessStruct.isOpen==false
        DAStudio.error('Simulink:Harness:CannotDeleteWhenSystemIsBusy',harnessName);
    end


    if bdIsLibrary(systemModel)&&strcmp('on',get_param(systemModel,'Lock'))
        DAStudio.error('Simulink:Harness:CannotDeleteHarnessWhenLibIsLocked',systemModel);
    end

    Simulink.harness.internal.checkFilesWritable(systemModel,harnessStruct,'delete',true);


    if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
        Simulink.harness.internal.deleteBDHarness(systemModel,harnessStruct.name);
    else
        Simulink.harness.internal.deleteHarness(systemModel,harnessStruct.name,harnessStruct.ownerHandle);
    end


    Simulink.harness.internal.refreshHarnessListDlg(harnessStruct.model);
end
