classdef PslinkContextManager<handle

    properties(Constant,Access=private)
        Instance=pslink.toolstrip.PslinkContextManager;
    end

    properties(GetAccess=private,SetAccess=immutable)
        ContextMap;
    end


    methods
        function obj=PslinkContextManager()
            mlock;
            obj.ContextMap=containers.Map('KeyType','double','ValueType','any');
        end
    end


    methods(Access=private)
        function data=get(obj,modelHandle)
            if obj.ContextMap.isKey(modelHandle)
                data=obj.ContextMap(modelHandle);
            else
                context=pslink.toolstrip.PslinkContext(modelHandle);
                mdlHandle=get_param(modelHandle,'Object');
                if isa(mdlHandle,'handle.handle')
                    listenr=handle.listener(...
                    mdlHandle,...
                    'CloseEvent',...
                    @i_closeCallback);
                else
                    listenr=listener(...
                    mdlHandle,...
                    'CloseEvent',...
                    @i_closeCallback);
                end
                data=struct('Context',context,'CloseListener',listenr);
                obj.ContextMap(modelHandle)=data;
            end
        end


        function data=remove(obj,modelHandle)
            data=obj.ContextMap(modelHandle);
            obj.ContextMap.remove(modelHandle);
        end
    end


    methods(Static,Access=public)
        function ctx=getContext(modelHandle)
            manager=pslink.toolstrip.PslinkContextManager.Instance;
            data=manager.get(modelHandle);
            ctx=data.Context;
        end


        function result=hasContext(modelHandle)
            manager=pslink.toolstrip.PslinkContextManager.Instance;
            result=manager.ContextMap.isKey(modelHandle);
        end


        function refresh
            manager=pslink.toolstrip.PslinkContextManager.Instance;
            for key=manager.ContextMap.keys
                data=manager.ContextMap(key{1});
                data.Context.refresh;
            end
        end
    end

end


function i_closeCallback(eventSrc,~)
    manager=pslink.toolstrip.PslinkContextManager.Instance;
    data=manager.remove(eventSrc.Handle);
    delete(data.CloseListener);
end