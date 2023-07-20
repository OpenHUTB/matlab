function initWorker(poolRoot,workerId,~,workerMLRoot)



    if desktop('-inuse')

        keyboard;
    end

    warnstat=warning('query','all');
    warning('off','MATLAB:DELETE:FileNotFound');
    warning('off','MATLAB:DELETE:Permission');
    wCleanup=onCleanup(@()warning(warnstat));

    workerInfo=stm.internal.MRT.mrtpool.getWorkerInfo(poolRoot,workerId);
    stm.internal.MRT.mrtpool.mrtPoolLocation(poolRoot);
    workerRelease=stm.internal.util.getReleaseInfo();


    if(strcmp(workerInfo.hostRelease,workerRelease))
        stm.internal.MRT.mrtpool.deleteWorkerFromPool(poolRoot,workerId,true);
        return;
    end


    cd(workerInfo.workerRoot);

    try
        if(exist(workerInfo.clickingFile,'file'))
            try
                delete(workerInfo.clickingFile);
            catch
            end
        end
    catch
    end

    fid=fopen(workerInfo.startedFile,'w');
    fprintf(fid,'%s\n',workerMLRoot);
    fclose(fid);


    workerPId='0000';
    try
        workerPId=num2str(feature('getpid'));
    catch
    end
    fid=fopen(workerInfo.workerPIdFile,'w');
    fprintf(fid,'%s\n',workerPId);
    fclose(fid);

    fid=fopen(workerInfo.runningFile,'w');
    fclose(fid);


    stm.internal.MRT.mrtpool.readWriteWorkStatus('started',true);
    callback=@(varargin)reportMyself(poolRoot,workerId);
    clickingTimer=timer('Name','sltestmrttimer');
    clickingTimer.ObjectVisibility='off';
    clickingTimer.TimerFcn=callback;
    clickingTimer.Period=1.5;
    clickingTimer.ExecutionMode='fixedRate';
    start(clickingTimer);


    exitML=true;
    cleanupWorkerObj=onCleanup(@()cleanupWorker(clickingTimer,poolRoot,workerId,exitML));
    try

        runningForever(poolRoot,workerId,workerInfo);
    catch


        exitML=true;
    end
    cleanupWorkerObj.delete();

end

function runningForever(poolRoot,workerId,workerInfo)
    addpath(workerInfo.todoFolder);
    c=onCleanup(@()rmpath(workerInfo.todoFolder));

    while(1)
        if(exist(workerInfo.exitFile,'file')||~stm.internal.MRT.mrtpool.checkWorker(poolRoot,workerId))
            break;
        end

        jobs=dir(fullfile(workerInfo.todoFolder,'*.m'));

        if(isempty(jobs))
            pause(1);
        end
        stm.internal.MRT.mrtpool.readWriteWorkStatus('no job found',true);

        for jobk=1:length(jobs)
            jobFile=fullfile(workerInfo.todoFolder,jobs(jobk).name);
            stm.internal.MRT.mrtpool.readWriteWorkStatus(sprintf('running %s',jobFile),true);
            [jobFolder,jobName,~]=fileparts(jobFile);
            try


                fid=fopen(fullfile(jobFolder,[jobName,'_ack']),'w');
                fclose(fid);
                eval(jobName);
            catch err
                errFile=fullfile(workerInfo.doneFolder,sprintf('%s.err.mat',jobName));
                save(errFile,'err');
            end
            if(exist(jobFile,'file'))
                movefile(jobFile,workerInfo.doneFolder,'f');
            end

            cd(workerInfo.workerRoot);
        end
    end
end

function reportMyself(poolRoot,workerId)
    status=stm.internal.MRT.mrtpool.readWriteWorkStatus('',false);
    workerInfo=stm.internal.MRT.mrtpool.getWorkerInfo(poolRoot,workerId);
    fid=fopen(workerInfo.clickingFile,'a');
    fprintf(fid,'>%s\n',datestr(now));
    fprintf(fid,'pwd = %s\n',pwd);
    fprintf(fid,'status = %s\n',status);
    fclose(fid);
end

function cleanupWorker(clickingTimer,poolRoot,workerId,exitML)
    stop(clickingTimer);
    delete(clickingTimer);
    stm.internal.MRT.mrtpool.deleteWorkerFromPool(poolRoot,workerId,exitML);
end


