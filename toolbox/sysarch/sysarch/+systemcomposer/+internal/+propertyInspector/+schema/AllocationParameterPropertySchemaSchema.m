classdef AllocationParameterPropertySchemaSchema<systemcomposer.internal.propertyInspector.schema.ParameterPropertySchema




    properties
    end

    methods

        function obj=AllocationParameterPropertySchemaSchema(elementWrapper,schemaFile,propertiesFile)

            obj=obj@systemcomposer.internal.propertyInspector.schema.ParameterPropertySchema(elementWrapper,schemaFile,propertiesFile);
        end

        function rendermode=getRenderMode(~,~)
            rendermode='text';
        end
    end
end

