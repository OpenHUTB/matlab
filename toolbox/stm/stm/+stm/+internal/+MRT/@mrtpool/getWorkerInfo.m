function worker=getWorkerInfo(poolRoot,workerId)




    worker=struct(...
...
    'poolRoot','',...
    'hostRelease','',...
    'hostReleaseFile','',...
    'hostMsgCatalog','',...
...
    'id','',...
    'workerRoot','',...
    'startedFile','',...
    'runningFile','',...
    'clickingFile','',...
    'todoFolder','',...
    'doneFolder','',...
    'exitFile','',...
    'workerMATLABRoot','',...
    'workerPId','',...
    'workerPIdFile',''...
    );

    if(nargin==0)
        poolRoot=stm.internal.MRT.mrtpool.mrtPoolLocation();




        if isempty(poolRoot)
            poolRoot=tempname(fullfile(tempdir,'_SimulinkTest_','_MRTPOOL_'));
            stm.internal.MRT.mrtpool.mrtPoolLocation(poolRoot);

        end
    end
    worker.poolRoot=poolRoot;

    worker.hostReleaseFile=fullfile(poolRoot,'host.release');
    if(exist(worker.hostReleaseFile,'file'))
        fid=fopen(worker.hostReleaseFile,'r');
        count=0;
        while fid<0&&count<10
            pause(0.1);
            fid=fopen(worker.hostReleaseFile,'r');
            count=count+1;
        end

        worker.hostRelease=fgetl(fid);
        fclose(fid);
    end
    worker.hostMsgCatalog=fullfile(poolRoot,'msgCatalog.mat');

    if(nargin==2)
        worker.id=workerId;
        worker.workerRoot=fullfile(poolRoot,workerId);
        worker.startedFile=fullfile(poolRoot,[workerId,'.started']);
        worker.runningFile=fullfile(poolRoot,[workerId,'.running']);
        worker.clickingFile=fullfile(poolRoot,[workerId,'.clicking']);

        worker.todoFolder=fullfile(worker.workerRoot,'TODO');
        worker.doneFolder=fullfile(worker.workerRoot,'DONE');
        worker.exitFile=fullfile(worker.todoFolder,'EXIT');

        if(exist(worker.startedFile,'file'))
            fid=fopen(worker.startedFile,'r');
            worker.workerMATLABRoot=fgetl(fid);
            fclose(fid);
        end

        worker.workerPIdFile=fullfile(poolRoot,[workerId,'.pid']);
        worker.workerPId='';
        if(exist(worker.workerPIdFile,'file'))
            fid=fopen(worker.workerPIdFile,'r');
            worker.workerPId=fgetl(fid);
            fclose(fid);
        end
    end
end
