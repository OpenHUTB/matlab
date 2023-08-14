classdef(Hidden)Logger<handle


    properties
Channel
    end

    methods
        function obj=Logger(channel)
            obj.Channel=channel;
            mlock;
        end

        function log(obj,type,message,varargin)
            connector.internal.Logger.doLog(obj.Channel,type,message,varargin{:});
        end

        function debug(obj,message,varargin)
            connector.internal.Logger.doLog(obj.Channel,...
            connector.internal.LoggerLevel.Debug,message,varargin{:});
        end

        function info(obj,message,varargin)
            connector.internal.Logger.doLog(obj.Channel,...
            connector.internal.LoggerLevel.Info,message,varargin{:});
        end

        function event(obj,message,varargin)
            connector.internal.Logger.doLog(obj.Channel,...
            connector.internal.LoggerLevel.Event,message,varargin{:});
        end

        function warning(obj,message,varargin)
            connector.internal.Logger.doLog(obj.Channel,...
            connector.internal.LoggerLevel.Warning,message,varargin{:});
        end

        function error(obj,message,varargin)
            connector.internal.Logger.doLog(obj.Channel,...
            connector.internal.LoggerLevel.Error,message,varargin{:});
        end

        function critical(obj,message,varargin)
            connector.internal.Logger.doLog(obj.Channel,...
            connector.internal.LoggerLevel.Critical,message,varargin{:});
        end
    end

    methods(Static)
        function doDebug(channel,message,varargin)
            connector.internal.Logger.doLog(channel,...
            connector.internal.LoggerLevel.Debug,message,varargin{:});
        end

        function doInfo(channel,message,varargin)
            connector.internal.Logger.doLog(channel,...
            connector.internal.LoggerLevel.Info,message,varargin{:});
        end

        function doEvent(channel,message,varargin)
            connector.internal.Logger.doLog(channel,...
            connector.internal.LoggerLevel.Event,message,varargin{:});
        end

        function doWarning(channel,message,varargin)
            connector.internal.Logger.doLog(channel,...
            connector.internal.LoggerLevel.Warning,message,varargin{:});
        end

        function doError(channel,message,varargin)
            connector.internal.Logger.doLog(channel,...
            connector.internal.LoggerLevel.Error,message,varargin{:});
        end

        function doCritical(channel,message,varargin)
            connector.internal.Logger.doLog(channel,...
            connector.internal.LoggerLevel.Critical,message,varargin{:});
        end


        function doLog(channel,type,message,varargin)
            stack=dbstack;

            func='';
            if numel(stack)>2
                func=sprintf('%s:%d',stack(3).name,stack(3).line);
            end

            if numel(varargin)>0
                connector.internal.log(channel,func,uint8(type),sprintf(message,varargin{:}));
            else
                connector.internal.log(channel,func,uint8(type),message);
            end
        end

    end
end
