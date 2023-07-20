classdef ParameterObjectWrapperCreator<SimulinkFixedPoint.WrapperCreator





    methods(Static)
        function wrapper=getWrapper(object,name,contextName)
            workspaceType=...
            SimulinkFixedPoint.AutoscalerVarSourceTypes.convertToEnumSourceType(object.slWorkspaceType);
            wrapper=SimulinkFixedPoint.WrapperCreator.getWrapper(object,name,contextName,workspaceType);
            setDataClassType(wrapper,'ParameterObjectData');
            setEntityAutoscalerID(wrapper,'DataObjectWrapper:Simulink.Parameter');
        end
    end
end


