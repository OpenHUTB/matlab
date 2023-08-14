classdef ProjectContextManager<handle




    properties(Constant,Access=private)
        Instance=Simulink.ModelManagement.Project.Toolstrip.ProjectContextManager;
    end

    properties(GetAccess=private,SetAccess=immutable)
        ContextMap;
    end

    methods(Access=private)
        function obj=ProjectContextManager()
            mlock;
            obj.ContextMap=containers.Map('KeyType','double','ValueType','any');
        end

        function data=get(obj,modelHandle)
            if obj.ContextMap.isKey(modelHandle)
                data=obj.ContextMap(modelHandle);
            else
                context=Simulink.ModelManagement.Project.Toolstrip.ProjectContext(modelHandle);
                mylistener=Simulink.listener(...
                get_param(modelHandle,'Object'),...
                'CloseEvent',...
                @(src,~)obj.remove(src.Handle));

                data=struct('Context',context,'CloseListener',mylistener);
                obj.ContextMap(modelHandle)=data;
            end
        end

        function remove(obj,modelHandle)
            data=obj.ContextMap(modelHandle);
            obj.ContextMap.remove(modelHandle);
            delete(data.CloseListener);
        end
    end

    methods(Static,Access=public)
        function ctx=getContext(modelHandle)
            manager=Simulink.ModelManagement.Project.Toolstrip.ProjectContextManager.Instance;
            data=manager.get(modelHandle);
            ctx=data.Context;
        end

        function result=hasContext(modelHandle)
            manager=Simulink.ModelManagement.Project.Toolstrip.ProjectContextManager.Instance;
            result=manager.ContextMap.isKey(modelHandle);
        end

        function refresh
            manager=Simulink.ModelManagement.Project.Toolstrip.ProjectContextManager.Instance;
            for key=manager.ContextMap.keys
                try
                    data=manager.ContextMap(key{1});
                    data.Context.refresh;
                catch
                    manager.remove(key{1});
                end
            end
        end
    end

end
