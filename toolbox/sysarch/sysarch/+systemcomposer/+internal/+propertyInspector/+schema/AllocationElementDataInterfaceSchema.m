classdef AllocationElementDataInterfaceSchema<systemcomposer.internal.propertyInspector.schema.AnonDataInterfaceElementSchema





    properties
    end

    methods

        function obj=AllocationElementDataInterfaceSchema(elementWrapper,schemaFile,propertiesFile)


            obj=obj@systemcomposer.internal.propertyInspector.schema.AnonDataInterfaceElementSchema(elementWrapper,schemaFile,propertiesFile);
        end

        function rendermode=getRenderMode(~,~)
            rendermode='text';
        end
    end
end

