classdef(Sealed,Hidden)DummyLogger<coderapp.internal.log.Logger

    properties(Constant,Hidden)
        IsDummy=true
    end

    properties(Transient)
Level
LogCaller
Sink
    end

    properties(SetAccess=immutable)
        IsRoot=true
    end

    properties(SetAccess=immutable,Transient)
        Parent=coderapp.internal.log.DummyLogger.empty()
    end

    methods(Static)
        function dummy=instance()
            persistent logger;
            if isempty(logger)||~isempty(logger)
                logger=coderapp.internal.log.DummyLogger();
            end
            dummy=logger;
        end
    end

    methods
        function scopeCleanup=log(~,varargin)
            scopeCleanup=[];
        end

        function scopeCleanup=trace(~,varargin)
            scopeCleanup=[];
        end

        function scopeCleanup=debug(~,varargin)
            scopeCleanup=[];
        end

        function scopeCleanup=info(~,varargin)
            scopeCleanup=[];
        end

        function scopeCleanup=warn(~,varargin)
            scopeCleanup=[];
        end

        function scopeCleanup=error(~,varargin)
            scopeCleanup=[];
        end

        function scopeCleanup=fatal(~,varargin)
            scopeCleanup=[];
        end

        function this=create(this,~)
        end

        function this=get(this,~)
        end

        function set.Sink(~,~)
        end

        function level=get.Level(~)
            level=coderapp.internal.log.LogLevel.Off;
        end

        function logCaller=get.LogCaller(~)
            logCaller=false;
        end
    end
end