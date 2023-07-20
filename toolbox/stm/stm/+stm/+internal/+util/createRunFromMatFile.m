function createRunFromMatFile(path,runID)



    ws=warning('off','SDI:sdi:notValidBaseWorkspaceVar');
    cleanupWarning=onCleanup(@()warning(ws));

    try
        load(path);
        Simulink.sdi.addToRun(runID,'namevalue',{'simOut'},{simOut});
        Simulink.sdi.addToRun(runID,'namevalue',{'verifyOut'},{verifyOut});
    catch
    end
end
