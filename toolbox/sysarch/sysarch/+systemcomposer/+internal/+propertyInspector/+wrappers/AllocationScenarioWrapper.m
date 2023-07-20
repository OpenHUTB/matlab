classdef AllocationScenarioWrapper<systemcomposer.internal.propertyInspector.wrappers.AllocationSetWrapper



    properties
    end

    methods
        function obj=AllocationScenarioWrapper(varargin)

            obj=obj@systemcomposer.internal.propertyInspector.wrappers.AllocationSetWrapper(varargin{:});
            obj.schemaType='AllocationScenario';
        end

        function tooltip=getNameTooltip(obj)

            tooltip=obj.getName;
        end
        function tooltip=getDescriptionTooltip(obj)

            tooltip=obj.getDescription;
        end
        function error=setName(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            try
                obj.element.setName(newValue);
            catch
                error=DAStudio.message('SystemArchitecture:PropertyInspector:FailedToSetName');
            end
        end
        function error=setDescription(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            try
                obj.element.p_Description=newValue;
            catch
                error=DAStudio.message('SystemArchitecture:PropertyInspector:FailedToSetDescription');
            end
        end
        function description=getDescription(obj)

            description=obj.element.p_Description;
        end
    end
end

