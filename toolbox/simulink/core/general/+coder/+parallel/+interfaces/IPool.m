classdef(Abstract)IPool<handle




    properties(Abstract,SetAccess=immutable)
IsLocalPool
IsThreadPool
NumWorkers
    end

    properties(Abstract,Dependent)
IsActive
    end

    methods(Abstract)
        varargout=runOnAllWorkersSync(~,func,varargin);
        future=runOnAllWorkersAsync(~,func,varargin)
        future=runOnWorkerAsync(~,func,varargin);
        workerCleanup=initializeWorkers(this);
        setupWorkersForModelRefBuilds(this,iMdl);
    end
end

