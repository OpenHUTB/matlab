
function harnessStruct=loadCodeContext(owner,name)
    try
        if slfeature('CodeContextHarness')==0
            DAStudio.error('Simulink:CodeContext:CodeContextFeatureNotOn');
        end

        owner=convertStringsToChars(owner);
        name=convertStringsToChars(name);

        [systemModel,harnessOwnerHandle]=Simulink.harness.internal.parseForSystemModel(owner);
        harnessStruct=Simulink.libcodegen.internal.getCodeContext(systemModel,harnessOwnerHandle,name);
        if isempty(harnessStruct)
            DAStudio.error('Simulink:CodeContext:CodeContextNotFound',getfullname(harnessOwnerHandle),name);
        end

        if harnessStruct.isOpen
            return;
        end

        if bdIsLoaded(name)&&~harnessStruct.canBeOpened
            DAStudio.error('Simulink:CodeContext:CodeContextOpenErrorModelOpen',name);
        end

        harnessStruct=Simulink.libcodegen.internal.loadContext(harnessStruct.model,harnessStruct.name,harnessStruct.ownerHandle);
    catch ME

        ME.throwAsCaller;
    end
end
