function success=addWorker(obj,workerId,matlabrootLoc,initLoc)








    if(nargin<4)
        initLoc='';
    end
    if(isempty(initLoc))
        initLoc=pwd();
    end

    obj.getWorkers();

    if(ispc)
        matlabExePath=fullfile(matlabrootLoc,'bin','matlab.exe');
    else
        matlabExePath=fullfile(matlabrootLoc,'bin','matlab');
    end
    if(~exist(matlabExePath,'file'))
        error(message('stm:MultipleReleaseTesting:MATLABInstallationNotFound',workerId));
    end
    pathInfo=what(matlabrootLoc);
    absPath=pathInfo.path;


    for k=1:length(obj.workerList)
        if(strcmp(obj.workerList(k).matlabroot,absPath)||...
            strcmp(obj.workerList(k).matlabroot,matlabrootLoc))
            return;
        end
    end
    if(strcmp(absPath,matlabroot)||strcmp(matlabrootLoc,matlabroot))
        return;
    end


    success=obj.addWorkerToPool(workerId,matlabrootLoc,initLoc);
    if(~success)
        error(message('stm:MultipleReleaseTesting:FailToLaunchRelease',workerId,matlabrootLoc));
    end
end
