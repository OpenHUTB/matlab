classdef mrtpool<handle



    properties(Access=private)
        poolRoot='';
        workerMap=containers.Map;
        workerList=repmat(struct('id','','matlabroot',''),0,1);
        msgData=[];
    end

    properties

        showDesktop=false;


        minimizeWindow=true;
    end

    methods(Access=private)
        function obj=mrtpool(poolRoot)
            obj.poolRoot=poolRoot;
        end
    end

    methods
        success=addWorker(obj,workerId,matlabrootLoc,initLoc);
        deleteWorker(obj,workerId);
        workers=getWorkers(obj);
        workerId=findWorkerByPath(obj,workerMLRoot);
        varargout=run(obj,workerId,script,outputVarNames,waitUntilFinish,...
        pathToAdd,pathToDelete);
        delete(obj);

        msg=getMessage(obj,msgId,varargin);
        msgVer=getMessageVersion(obj);
    end

    methods(Hidden)
        function poolRoot=getRoot(obj)
            poolRoot=obj.poolRoot;
        end
    end

    methods(Access=private)
        success=addWorkerToPool(obj,workerId,workerMLRoot,initLoc);
        loadMessgeData(obj);
    end

    methods(Static)

        singleObj=getInstance(createPool);
        loc=mrtPoolLocation(varargin);
    end

    methods(Static,Hidden)
        initWorker(poolRoot,workerId,initLoc,workerMLRoot);
        status=readWriteWorkStatus(statusString,bUpdate);
        worker=getWorkerInfo(poolRoot,workerId);
        status=checkWorker(poolRoot,workerId);
    end
    methods(Static,Access=private)
        deleteWorkerFromPool(poolRoot,workerId,exitMATLAB);
    end
end