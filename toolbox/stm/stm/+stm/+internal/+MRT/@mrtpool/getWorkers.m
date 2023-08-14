function workers=getWorkers(obj)




    fileList=dir(fullfile(obj.poolRoot,'*.started'));
    nWorkers=length(fileList);

    obj.workerMap=containers.Map;
    obj.workerList=repmat(struct('id','','matlabroot',''),0,1);
    for k=1:nWorkers
        [~,id,~]=fileparts(fileList(k).name);

        workerInfo=stm.internal.MRT.mrtpool.getWorkerInfo(obj.poolRoot,id);
        fid=fopen(workerInfo.startedFile,'r');
        if(fid<0)
            obj.deleteWorker(id);
            continue;
        end
        mlRootLoc=fgetl(fid);
        fclose(fid);
        if(exist(mlRootLoc,'dir'))
            worker=struct('id',id,'matlabroot',mlRootLoc);
            obj.workerList(end+1)=worker;
            obj.workerMap(id)=length(obj.workerList);
        else
            obj.deleteWorker(id);
        end
    end
    workers=obj.workerList;
end
