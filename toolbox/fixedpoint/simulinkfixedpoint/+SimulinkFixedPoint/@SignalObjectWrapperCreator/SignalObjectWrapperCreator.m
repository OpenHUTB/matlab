classdef SignalObjectWrapperCreator<SimulinkFixedPoint.WrapperCreator





    methods(Static)
        function wrapper=getWrapper(object,name,contextName)
            workspaceType=...
            SimulinkFixedPoint.AutoscalerVarSourceTypes.convertToEnumSourceType(object.slWorkspaceType);
            wrapper=SimulinkFixedPoint.WrapperCreator.getWrapper(object,name,contextName,workspaceType);
            setDataClassType(wrapper,'SignalObjectData');
            setEntityAutoscalerID(wrapper,'DataObjectWrapper:Simulink.Signal');
        end
    end
end


