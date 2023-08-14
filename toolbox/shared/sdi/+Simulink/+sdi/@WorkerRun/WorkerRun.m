classdef WorkerRun<handle













    methods


        function this=WorkerRun(runID)
            if nargin>0
                eng=Simulink.sdi.Instance.engine;
                this.WorkerInstanceID=...
                getInstanceID(eng.sigRepository);
                this.WorkerRunID=runID;
            end
        end


        function ret=getLocalRun(this)
            ret=[];
            runID=getLocalRunID(this);
            if runID
                ret=Simulink.sdi.getRun(runID);
            end
        end


        function ret=getDataset(this,varargin)
            ret=[];
            runID=getLocalRunID(this);
            if runID
                ret=Simulink.sdi.internal.createRepositoryBackedDataset(runID,varargin{:});
            end
        end


        function ret=getDatasetRef(this,varargin)
            ret=[];
            runID=getLocalRunID(this);
            if runID
                ret=Simulink.sdi.DatasetRef(runID,varargin{:});
            end
        end

    end


    methods(Static=true)


        function ret=getLatest()
            ret=Simulink.sdi.WorkerRun();
            runIDs=Simulink.sdi.getAllRunIDs();
            if~isempty(runIDs)
                ret=Simulink.sdi.WorkerRun(runIDs(end));
            end
        end

    end


    methods(Access=private)


        function ret=getLocalRunID(this)
            eng=Simulink.sdi.Instance.engine();
            thisInstanceID=getInstanceID(eng.sigRepository);
            if thisInstanceID==this.WorkerInstanceID
                ret=this.WorkerRunID;
            elseif this.WorkerInstanceID&&this.WorkerRunID



                MAX_RETRIES=10;
                for idx=1:MAX_RETRIES
                    ret=getWorkerRunID(...
                    eng.sigRepository,this.WorkerInstanceID,this.WorkerRunID);
                    if ret
                        return
                    else
                        pause(0.5);
                    end
                end
            else
                ret=0;
            end
        end

    end


    properties(Access=private)
        WorkerInstanceID=int64(0)
        WorkerRunID=int32(0)
    end
end
