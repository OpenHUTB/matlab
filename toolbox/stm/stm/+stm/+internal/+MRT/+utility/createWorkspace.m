function workspaceRoot=createWorkspace(rsId,nWorkers,cleanWorkspace)



    workspaceRoot=stm.internal.createWorkspace(rsId,nWorkers,cleanWorkspace);

    workerfolder=fullfile(workspaceRoot,'Workers');

    warnstat=warning('query','all');
    warning('off','MATLAB:DELETE:FileNotFound');
    warning('off','MATLAB:DELETE:Permission');
    wCleanup=onCleanup(@()warning(warnstat));

    try
        delete(fullfile(workerfolder,'worker*.*'));
    catch
    end
end
