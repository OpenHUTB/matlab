function cleanupWorkers(pool)






    if~pool.IsActive
        return;
    end


    msg=DAStudio.message('Simulink:slbuild:parBuildCleanup');
    slprivate('sl_disp_info',msg,true);

    pool.runOnAllWorkersSync(@locCleanupWorker);

end

function locCleanupWorker

    Simulink.fileGenControl('clearBuildInProgress');


    cache=coder.parallel.worker.Cache.getInstance;


    Simulink.fileGenControl('setconfig','config',cache.FileGenConfig);




    cd(cache.StartDir);


    delete(cache);


    Simulink.filegen.internal.FolderConfiguration.clearCache();


    Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum.getInstance('delete');



    bdclose all;


    evalin('base','clear variables');
end

