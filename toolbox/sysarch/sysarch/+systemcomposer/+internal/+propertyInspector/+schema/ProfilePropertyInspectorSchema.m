classdef ProfilePropertyInspectorSchema<systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema



    properties
    end

    methods
        function obj=ProfilePropertyInspectorSchema(elementWrapper)
            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema(elementWrapper,'ProfileEditorPropertyInspector.json','profileEditorProperties.json');
        end

        function schema=getSubSchema(obj,propID)
            idArray=strsplit(propID,':');
            switch(idArray{end})
            case 'PropertyTableSchema'
                tableSchemaClass=systemcomposer.internal.propertyInspector.schema.StereotypePropertyElementSchema(obj.elementWrapper);
                schema=tableSchemaClass.getPropertyTableSchema();
            otherwise
                schema={};
            end
        end
    end
end

