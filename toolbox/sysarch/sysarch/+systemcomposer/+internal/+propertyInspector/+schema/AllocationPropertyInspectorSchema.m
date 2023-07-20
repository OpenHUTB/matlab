classdef AllocationPropertyInspectorSchema<systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema





    properties
    end

    methods
        function obj=AllocationPropertyInspectorSchema(elemWrap)


            schemaFile='AllocationEditorPropertyInspector.json';
            propertiesFile='allocationProperties.json';

            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema(elemWrap,schemaFile,propertiesFile);
        end

        function element=getPropElement(obj)
            element=obj.elementWrapper.getPropElement;
        end
        function schema=addDynamicPropertyAfter(obj,propID)
            idArray=strsplit(propID,':');
            switch(idArray{end})
            case 'Stereotype'
                appliedStereotypeSchemaClass=systemcomposer.internal.propertyInspector.schema.AllocationStereotypeSchema(obj.elementWrapper,obj.schemaFile,obj.propertiesFile);
                schema=appliedStereotypeSchemaClass.getSchema();
                keys=appliedStereotypeSchemaClass.propertyIDMap.keys;
                for ki=1:numel(keys)
                    obj.propertyIDMap(keys{ki})=appliedStereotypeSchemaClass.propertyIDMap(keys{ki});
                end
            otherwise
                schema={};
            end
        end
        function schema=getPropertiesSchema(obj,properties,parentID)
            if isa(obj.elementWrapper,'systemcomposer.internal.propertyInspector.wrappers.AllocationWrapper')


                if slfeature("AllocationStereotypes")==0||isempty(obj.elementWrapper.allocation)
                    properties(end)=[];
                end
            end
            schema=getPropertiesSchema@systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema(obj,properties,parentID);
        end
        function schema=getSubSchema(obj,propID)
            idArray=strsplit(propID,':');
            switch(idArray{end})
            case 'SourceLinkSchema'
                sourceSchemaID=['Allocation',obj.elementWrapper.sourceElemType];
                sourceSchemaClass=systemcomposer.internal.propertyInspector.schema.AllocationElementSchema(obj.elementWrapper.sourceElemWrapper,obj.schemaFile,obj.propertiesFile);



                schema=sourceSchemaClass.getAllocationElementSchema(sourceSchemaID,propID);
            case 'TargetLinkSchema'
                targetSchemaID=['Allocation',obj.elementWrapper.targetElemType];
                targetSchemaClass=systemcomposer.internal.propertyInspector.schema.AllocationElementSchema(obj.elementWrapper.targetElemWrapper,obj.schemaFile,obj.propertiesFile);


                schema=targetSchemaClass.getAllocationElementSchema(targetSchemaID,propID);
            otherwise
                schema={};
            end
        end
    end
end

