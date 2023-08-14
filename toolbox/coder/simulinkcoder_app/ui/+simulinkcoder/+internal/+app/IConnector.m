classdef(Abstract)IConnector<handle




    methods(Abstract)
        publish(~,channel,msg,varargin)
        out=subscribe(~,channel,callback,varargin)
        unsubscribe(~,sub,varargin)
    end
end