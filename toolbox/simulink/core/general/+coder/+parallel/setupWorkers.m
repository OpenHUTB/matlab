function workerCleanup=setupWorkers(pool)




    msg=DAStudio.message('Simulink:slbuild:parBuildInit');
    slprivate('sl_disp_info',msg,true);


    clientFileGenConfig=Simulink.fileGenControl('getConfig');


    [hostCAPINeeded,lightWeightRTWCAPINeeded]=coder.internal.ModelCAPIMgr.managePersistentVars('get');





    buildFolderCache=Simulink.filegen.internal.BuildFolderCache.getInstance();



    pool.runOnAllWorkersSync(@locSetupWorker,buildFolderCache,clientFileGenConfig,...
    hostCAPINeeded,lightWeightRTWCAPINeeded);

    msg=DAStudio.message('Simulink:slbuild:parBuildInitComplete');
    slprivate('sl_disp_info',msg,true);


    workerCleanup=onCleanup(@()coder.parallel.cleanupWorkers(pool));

end

function locSetupWorker(buildFolderCache,clientFileGenConfig,...
    hostCAPINeeded,lightWeightRTWCAPINeeded)


    Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum.getInstance('delete');



    bdclose all;



    Simulink.fileGenControl('clearBuildInProgress');


    Simulink.filegen.internal.BuildFolderCache.setInstance(buildFolderCache);



    cache=coder.parallel.worker.Cache.getInstance;


    cache.FileGenConfig=Simulink.fileGenControl('getinternalconfig');
    cache.StartDir=pwd;





    Simulink.fileGenControl('setConfig','config',clientFileGenConfig);




    Simulink.fileGenControl('setBuildInProgress');





    coder.internal.ModelCAPIMgr.managePersistentVars(...
    'set',hostCAPINeeded,lightWeightRTWCAPINeeded);
end


