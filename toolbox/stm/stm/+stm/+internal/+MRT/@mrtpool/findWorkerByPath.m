function workerId=findWorkerByPath(obj,workerMLRoot)




    obj.getWorkers();

    pathInfo=what(workerMLRoot);
    absPath=pathInfo.path;

    workerId='';
    for k=1:length(obj.workerList)


        if(strcmp(obj.workerList(k).matlabroot,absPath)||...
            strcmp(workerMLRoot,obj.workerList(k).matlabroot))
            workerId=obj.workerList(k).id;
            break;
        end
    end
end
