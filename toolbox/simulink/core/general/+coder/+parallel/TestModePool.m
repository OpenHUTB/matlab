classdef TestModePool<coder.parallel.interfaces.IPool





    properties(SetAccess=immutable)
IsLocalPool
IsThreadPool
NumWorkers
    end

    properties(Dependent)
IsActive
    end

    methods



        function this=TestModePool(~)
            this.IsLocalPool=true;
            this.IsThreadPool=false;
            this.NumWorkers=0;
        end




        function isActive=get.IsActive(~)

            isActive=true;
        end




        function varargout=runOnAllWorkersSync(~,func,varargin)

            [varargout{1:nargout}]=func(varargin{:});
        end




        function future=runOnAllWorkersAsync(~,~,varargin)%#ok
            assert(false,'Not implemented');
        end




        function future=runOnWorkerAsync(~,func,varargin)
            [result{1:nargout(func)}]=func(varargin{:});
            future=coder.parallel.TestModeFuture(result);
        end




        function workerCleanup=initializeWorkers(~,~)

            workerCleanup=[];
        end




        function setupWorkersForModelRefBuilds(~,~,~,~)

        end
    end
end


