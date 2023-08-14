classdef AllocationElementPropertyInspectorSchema<systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema





    properties
    end

    methods
        function obj=AllocationElementPropertyInspectorSchema(elemWrap)

            schemaFile='AllocationEditorPropertyInspector.json';
            propertiesFile='allocationProperties.json';

            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema(elemWrap,schemaFile,propertiesFile);
        end

        function schema=getPropertiesSchema(obj,~,parentID)
            elementSchemaID=['Allocation',obj.elementWrapper.sourceElemType];
            elementSchemaClass=systemcomposer.internal.propertyInspector.schema.AllocationElementSchema(obj.elementWrapper.sourceElemWrapper,obj.schemaFile,obj.propertiesFile);
            schema=elementSchemaClass.getAllocationElementSchema(elementSchemaID,parentID);
        end
    end
end

