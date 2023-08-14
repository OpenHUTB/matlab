classdef RunOnceListener<handle



    properties(Access=private)
        RunOnceFunction;
        ListenerHandle;
    end

    methods(Access=public)
        function obj=RunOnceListener(listenerFunction,observer,eventName)
            obj.RunOnceFunction=listenerFunction;
            obj.ListenerHandle=observer.addlistener(eventName,@obj.fireOnce);
        end

    end

    methods(Access=private)
        function fireOnce(obj,varargin)
            obj.RunOnceFunction(varargin);
            obj.ListenerHandle.delete();
        end
    end

end