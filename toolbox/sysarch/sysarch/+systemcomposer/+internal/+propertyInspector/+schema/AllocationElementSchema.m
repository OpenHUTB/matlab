classdef AllocationElementSchema<systemcomposer.internal.propertyInspector.schema.StereotypePropertySchema




    properties
    end

    methods
        function obj=AllocationElementSchema(elementWrapper,schemaFile,propertiesFile)


            obj=obj@systemcomposer.internal.propertyInspector.schema.StereotypePropertySchema(elementWrapper,schemaFile,propertiesFile);
        end

        function schema=getAllocationElementSchema(obj,schemaID,parentID)
            schema=obj.getPropertySubSchema(schemaID,parentID);
        end

        function schema=addDynamicPropertyAfter(obj,propID)
            idArray=strsplit(propID,':');
            switch(idArray{end})
            case{'Main','Interface'}
                appliedStereotypeSchemaClass=systemcomposer.internal.propertyInspector.schema.AllocationStereotypeSchema(obj.elementWrapper,obj.schemaFile,obj.propertiesFile);
                schema=appliedStereotypeSchemaClass.getSchema();
            case 'InterfaceAction'
                if(isequal(obj.elementWrapper.element.getPortAction,systemcomposer.architecture.model.core.PortAction.PHYSICAL))
                    elementSchema=systemcomposer.internal.propertyInspector.schema.AllocationElementPhysicalInterfaceSchema(obj.elementWrapper,obj.schemaFile,obj.propertiesFile);
                else
                    elementSchema=systemcomposer.internal.propertyInspector.schema.AllocationElementDataInterfaceSchema(obj.elementWrapper,obj.schemaFile,obj.propertiesFile);
                end
                schema=elementSchema.getSchema();
            case 'ParameterSection'
                paramSchemaClass=systemcomposer.internal.propertyInspector.schema.AllocationParameterPropertySchemaSchema(obj.elementWrapper,obj.schemaFile,obj.propertiesFile);
                schema=paramSchemaClass.getSchema();
                if~isempty(schema)
                    if obj.propertyIDMap.isKey(propID)
                        tempSchema=obj.propertyIDMap(propID);
                        tempSchema.children=schema;
                        obj.propertyIDMap(propID)=tempSchema;
                    end
                    schema={};
                end
            otherwise
                schema={};
            end
        end
        function renderMode=getRenderMode(~)
            renderMode='text';
        end
    end
end

