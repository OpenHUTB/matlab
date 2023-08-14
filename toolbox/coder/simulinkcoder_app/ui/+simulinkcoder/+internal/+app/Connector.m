classdef Connector<simulinkcoder.internal.app.IConnector




    methods
        function publish(~,channel,msg,varargin)

            message.publish(channel,msg,varargin{:});
        end

        function out=subscribe(~,channel,callback,varargin)

            out=message.subscribe(channel,callback,varargin{:});
        end

        function unsubscribe(~,sub,varargin)

            message.unsubscribe(sub,varargin{:});
        end
    end
end