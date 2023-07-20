classdef BreakpointObjectWrapperCreator<SimulinkFixedPoint.WrapperCreator





    methods(Static)
        function wrapper=getWrapper(object,name,contextName,workspaceType)
            wrapper=SimulinkFixedPoint.WrapperCreator.getWrapper(object,name,contextName,workspaceType);
            setDataClassType(wrapper,'ParameterObjectData');
            setEntityAutoscalerID(wrapper,'DataObjectWrapper:Simulink.Breakpoint');
        end
    end
end


