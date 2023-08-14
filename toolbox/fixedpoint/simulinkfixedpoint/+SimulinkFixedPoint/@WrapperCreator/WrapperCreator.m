classdef WrapperCreator<handle





    methods(Static)
        function wrapper=getWrapper(object,name,contextName,workspaceType)
            wrapper=SimulinkFixedPoint.DataObjectWrapper;
            setObject(wrapper,object);
            setName(wrapper,name);
            setContextName(wrapper,contextName);
            setWorkspaceType(wrapper,workspaceType);
            executePrebuildOperations(wrapper);
        end
    end
end


