classdef AllocationElementPhysicalInterfaceSchema<systemcomposer.internal.propertyInspector.schema.AnonPhysicalInterfaceElementSchema





    properties
    end

    methods

        function obj=AllocationElementPhysicalInterfaceSchema(elementWrapper,schemaFile,propertiesFile)


            obj=obj@systemcomposer.internal.propertyInspector.schema.AnonPhysicalInterfaceElementSchema(elementWrapper,schemaFile,propertiesFile);
        end

        function rendermode=getRenderMode(~,~)
            rendermode='text';
        end
    end
end

