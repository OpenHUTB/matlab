classdef AllocationStereotypeSchema<systemcomposer.internal.propertyInspector.schema.StereotypePropertySchema





    properties
        isReadOnly=true;
        DEL_STEREOTYPE_ICN='delete_16';
        RESET_PROPS_TO_DEFAULT_ICN='refresh_16';
    end

    methods
        function obj=AllocationStereotypeSchema(elementWrapper,schemaFile,propertiesFile)


            obj=obj@systemcomposer.internal.propertyInspector.schema.StereotypePropertySchema(elementWrapper,schemaFile,propertiesFile);
            obj.isReadOnly=~isa(elementWrapper,'systemcomposer.internal.propertyInspector.wrappers.AllocationWrapper');
        end

        function renderMode=getRenderMode(obj,propertyUsage)

            if obj.isReadOnly

                renderMode='text';
            else

                renderMode=getRenderMode@systemcomposer.internal.propertyInspector.schema.StereotypePropertySchema(obj,propertyUsage);
            end
        end

        function enabled=isEditable(obj,~)
            enabled=~obj.isReadOnly();
        end

        function schema=getSchema(obj)
            schema=getSchema@systemcomposer.internal.propertyInspector.schema.StereotypePropertySchema(obj);
            if~obj.isReadOnly
                for si=1:numel(schema)
                    schema{si}.editable=1;
                    schema{si}.entries={obj.DEL_STEREOTYPE_ICN,obj.RESET_PROPS_TO_DEFAULT_ICN};
                    schema{si}.renderMode='actioncallback';
                    schema{si}.value='';
                    schema{si}.setter="@setAppliedStereotypeAction";
                end
            end
        end
    end
end

