classdef(Abstract)Logger<handle


    properties(Transient)
        Label{mustBeTextScalar(Label)}=''
        Formatter function_handle{mustBeScalarOrEmpty(Formatter)}
        EnableDataLogging(1,1){mustBeNumericOrLogical(EnableDataLogging)}=true
        EnableBubbling(1,1){mustBeNumericOrLogical(EnableBubbling)}=true
    end

    properties(Abstract,Transient)
Level
LogCaller
        Sink coderapp.internal.log.LogSink
    end

    properties(Abstract,SetAccess=immutable)
        IsRoot(1,1)logical
    end

    properties(Abstract,SetAccess=immutable,Transient)
        Parent coderapp.internal.log.Logger{mustBeScalarOrEmpty(Parent)}
    end

    properties(Abstract,Constant,Hidden)
        IsDummy(1,1)logical
    end

    properties(Constant,Hidden)
        HAS_LOGGER_IMPL=~isempty(which('coderapp.dev.log.LoggerImpl'))
    end

    methods(Static)
        function logger=createRoot(varargin)
            if coderapp.internal.log.Logger.HAS_LOGGER_IMPL
                logger=coderapp.dev.log.LoggerImpl.createRoot(varargin{:});
            else
                logger=coderapp.internal.log.DummyLogger();
            end
        end
    end

    methods(Abstract)

        scopeCleanup=log(this,level,arg,varargin)

        scopeCleanup=trace(this,arg,varargin)

        scopeCleanup=debug(this,arg,varargin)

        scopeCleanup=info(this,arg,varargin)

        scopeCleanup=warn(this,arg,varargin)

        scopeCleanup=error(this,arg,varargin)

        scopeCleanup=fatal(this,arg,varargin)

        childLogger=create(this,id,level)

        childLogger=get(this,id)
    end

    methods(Static,Hidden)
        function wrapped=html(text)
            wrapped=['<html>',char(text),'</html>'];
        end
    end
end