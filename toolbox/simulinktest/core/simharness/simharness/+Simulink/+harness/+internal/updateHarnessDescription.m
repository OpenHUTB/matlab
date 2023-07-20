function updateHarnessDescription(bdHandle,description)

    if~ishandle(bdHandle)
        return;
    end

    try
        hInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(bdHandle);
        if~isempty(hInfo)&&~Simulink.harness.internal.isInAtomicAction
            Simulink.harness.set(hInfo.ownerFullPath,hInfo.name,'Description',...
            description);
        end
    catch ME %#ok

    end

end