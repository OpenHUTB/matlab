classdef NamedTypeObjectWrapperCreator<SimulinkFixedPoint.WrapperCreator





    methods(Static)
        function wrapper=getWrapper(object,name,contextName,workspaceType)
            wrapper=SimulinkFixedPoint.WrapperCreator.getWrapper(object,name,contextName,workspaceType);
            setDataClassType(wrapper,'NamedTypeData');
            setEntityAutoscalerID(wrapper,...
            ['DataObjectWrapper:',SimulinkFixedPoint.NamedTypeObjectWrapperCreator.getID(object)]);
        end
        function id=getID(dataObject)





            if isa(dataObject,'Simulink.NumericType')
                id='Simulink.NumericType';
            elseif isa(dataObject,'embedded.numerictype')
                id='embedded.numerictype';
            elseif isa(dataObject,'Simulink.AliasType')
                id='Simulink.AliasType';
            end
        end
    end
end


