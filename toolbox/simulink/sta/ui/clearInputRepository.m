function clearInputRepository()





    map=Simulink.sta.StaDialog.getPersistentHashMap;

    if map.Count~=0

        MSLDiagnostic('sl_sta:sta:clearInputRepositoryWarn').reportAsWarning;
        return;
    end

    repoMgr=sta.RepositoryManager();
    removeAllSTAEntries(repoMgr);
