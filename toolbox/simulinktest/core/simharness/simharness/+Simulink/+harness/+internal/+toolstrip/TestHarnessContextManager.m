classdef TestHarnessContextManager<handle




    properties(Constant,Access=private)
        Instance=Simulink.harness.internal.toolstrip.TestHarnessContextManager;
    end

    properties(GetAccess=private,SetAccess=immutable)
        ContextMap;
    end

    methods(Access=private)
        function obj=TestHarnessContextManager()
            mlock;
            obj.ContextMap=containers.Map('KeyType','double','ValueType','any');
        end

        function data=get(obj,modelHandle)
            if obj.ContextMap.isKey(modelHandle)
                data=obj.ContextMap(modelHandle);
            else
                context=Simulink.harness.internal.toolstrip.TestHarnessContext(modelHandle);
                mylistener=Simulink.listener(...
                get_param(modelHandle,'Object'),...
                'CloseEvent',...
                @i_closeCallback);
                data=struct('Context',context,'CloseListener',mylistener);
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
            manager=Simulink.harness.internal.toolstrip.TestHarnessContextManager.Instance;
            data=manager.get(modelHandle);
            ctx=data.Context;
        end

        function result=hasContext(modelHandle)
            manager=Simulink.harness.internal.toolstrip.TestHarnessContextManager.Instance;
            result=manager.ContextMap.isKey(modelHandle);
        end

        function refresh
            manager=Simulink.harness.internal.toolstrip.TestHarnessContextManager.Instance;
            for key=manager.ContextMap.keys
                data=manager.ContextMap(key{1});
                data.Context.refresh;
            end
        end
    end

end

function i_closeCallback(eventSrc,~)
    manager=Simulink.harness.internal.toolstrip.TestHarnessContextManager.Instance;
    data=manager.remove(eventSrc.Handle);
    delete(data.CloseListener);
end
