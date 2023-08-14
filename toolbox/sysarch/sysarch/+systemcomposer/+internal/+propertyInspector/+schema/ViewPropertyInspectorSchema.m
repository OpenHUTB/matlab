classdef ViewPropertyInspectorSchema<systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema





    properties
    end

    methods
        function obj=ViewPropertyInspectorSchema(elemWrap)


            schemaFile='ViewsEditorPropertyInspector.json';

            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema(elemWrap,schemaFile);
        end

        function element=getPropElement(obj)
            element=obj.elementWrapper.getPropElement;
        end

        function schema=addDynamicPropertyAfter(obj,propID)
            idArray=strsplit(propID,':');
            switch(idArray{end})
            case 'Stereotype'
                appliedStereotypeSchemaClass=systemcomposer.internal.propertyInspector.schema.StereotypePropertySchema(obj.elementWrapper,obj.schemaFile,obj.propertiesFile);
                schema=appliedStereotypeSchemaClass.getSchema();
            case 'InterfaceAction'
                if(isequal(obj.elementWrapper.element.getPortAction,systemcomposer.architecture.model.core.PortAction.PHYSICAL))
                    elementSchema=systemcomposer.internal.propertyInspector.schema.AnonPhysicalInterfaceElementSchema(obj.elementWrapper,obj.schemaFile,obj.propertiesFile);
                else
                    elementSchema=systemcomposer.internal.propertyInspector.schema.AnonDataInterfaceElementSchema(obj.elementWrapper,obj.schemaFile,obj.propertiesFile);
                end
                schema=elementSchema.getSchema();
            otherwise
                schema={};
            end
        end
    end
end

