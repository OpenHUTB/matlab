classdef Pool<coder.parallel.interfaces.IPool




    properties(SetAccess=immutable)
IsLocalPool
IsThreadPool
NumWorkers
    end

    properties(Dependent)
IsActive
    end

    methods



        function this=Pool(pctPool)
            this.IsLocalPool=isa(pctPool,'parallel.ProcessPool');
            this.IsThreadPool=isa(pctPool,'parallel.ThreadPool');
            this.NumWorkers=pctPool.NumWorkers;
        end




        function isActive=get.IsActive(~)

            isActive=~isempty(gcp('nocreate'));
        end




        function varargout=runOnAllWorkersSync(~,func,varargin)




            numOutputs=nargout;
            pctFuture=parfevalOnAll(func,numOutputs,varargin{:});
            [varargout{1:numOutputs}]=fetchOutputs(pctFuture);

            diary=strjoin(pctFuture.Diary,'');
            if~isempty(diary)
                Simulink.output.info(diary);
            end
        end




        function future=runOnAllWorkersAsync(~,func,varargin)


            future=parfevalOnAll(func,nargout(func),varargin{:});
        end




        function future=runOnWorkerAsync(~,func,varargin)





            pctFuture=parfeval(func,nargout(func),varargin{:});
            future=coder.parallel.Future(pctFuture);
        end




        function workerCleanup=initializeWorkers(this)
            workerCleanup=coder.parallel.setupWorkers(this);
        end




        function setupWorkersForModelRefBuilds(this,iMdl)
            coder.parallel.setupWorkersForModelRefBuilds(this,iMdl);
        end
    end
end


