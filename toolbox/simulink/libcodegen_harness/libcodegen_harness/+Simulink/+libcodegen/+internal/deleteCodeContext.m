
function deleteCodeContext(harnessOwner,harnessName)

    if slfeature('CodeContextHarness')==0
        DAStudio.error('Simulink:CodeContext:CodeContextFeatureNotOn');
    end

    [systemModel,harnessOwnerHandle]=Simulink.harness.internal.parseForSystemModel(harnessOwner);
    harnessStruct=Simulink.libcodegen.internal.getCodeContext(systemModel,harnessOwnerHandle,harnessName);
    if isempty(harnessStruct)
        DAStudio.error('Simulink:CodeContext:CodeContextNotFound',getfullname(harnessOwnerHandle),harnessName);
    end

    try
        Simulink.harness.internal.checkFilesWritable(systemModel,harnessStruct,'delete',true);
    catch ME
        mainError=MSLException([],message('Simulink:CodeContext:CodeContextDeleteError',harnessName));
        mainError.addCause(ME);
        mainError.throwAsCaller();
    end

    activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);


    if harnessStruct.isOpen
        DAStudio.error('Simulink:CodeContext:CannotDeleteLockedOrOpenCodeContext');
    end


    if harnessStruct.canBeOpened==false&&~isempty(activeHarness)...
        &&activeHarness.ownerHandle~=harnessStruct.ownerHandle
        DAStudio.error('Simulink:CodeContext:CannotDeleteWhenATestingHarnessIsActive',harnessName);
    end


    if harnessStruct.canBeOpened==false&&harnessStruct.isOpen==false
        DAStudio.error('Simulink:CodeContext:CannotDeleteWhenSystemIsBusy',harnessName);
    end


    if bdIsLibrary(systemModel)&&strcmp('on',get_param(systemModel,'Lock'))
        DAStudio.error('Simulink:CodeContext:CannotDeleteCodeContextWhenLibIsLocked',systemModel);
    end


    Simulink.libcodegen.internal.deleteContext(systemModel,harnessStruct.name,...
    harnessStruct.ownerHandle);


    hInfo=Simulink.harness.internal.find(harnessStruct.ownerHandle,'FunctionInterfaceName',harnessStruct.name);
    if~isempty(hInfo)
        for i=1:length(hInfo)
            Simulink.harness.internal.set(hInfo(i).ownerHandle,hInfo(i).name,'FunctionInterfaceName','');
        end
    end


end
