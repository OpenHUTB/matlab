classdef MulticoreContextManager<handle




    properties(Constant,Access=private)
        Instance=multicoredesigner.internal.MulticoreContextManager;
    end

    properties(GetAccess=private,SetAccess=immutable)
        ContextMap;
    end

    methods(Access=private)
        function obj=MulticoreContextManager()
            mlock;
            obj.ContextMap=containers.Map('KeyType','double','ValueType','any');
        end

        function data=get(obj,modelHandle)
            if obj.ContextMap.isKey(modelHandle)
                data=obj.ContextMap(modelHandle);
            else
                app=struct;
                app.name='multicoreDesignerApp';
                app.defaultContextType='multicoreDesignerContext';
                app.defaultTabName='';
                app.priority=0;
                context=multicoredesigner.internal.MulticoreDesignerContext(app,modelHandle);
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
            manager=multicoredesigner.internal.MulticoreContextManager.Instance;
            data=manager.get(modelHandle);
            ctx=data.Context;
        end
        function deleteContext(modelHandle)
            manager=multicoredesigner.internal.MulticoreContextManager.Instance;
            if manager.ContextMap.isKey(modelHandle)
                manager.remove(modelHandle);
            end
        end

        function result=hasContext(modelHandle)
            manager=multicoredesigner.internal.MulticoreContextManager.Instance;
            result=manager.ContextMap.isKey(modelHandle);
        end

        function refresh
            manager=multicoredesigner.internal.MulticoreContextManager.Instance;
            for key=manager.ContextMap.keys
                data=manager.ContextMap(key{1});
                data.Context.refresh;
            end
        end
    end

end


function i_closeCallback(eventSrc,~)
    manager=multicoredesigner.internal.MulticoreContextManager.Instance;
    data=manager.remove(eventSrc.Handle);
    delete(data.CloseListener);
end
