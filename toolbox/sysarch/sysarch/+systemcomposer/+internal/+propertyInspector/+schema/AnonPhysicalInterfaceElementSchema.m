classdef AnonPhysicalInterfaceElementSchema<systemcomposer.internal.propertyInspector.schema.PropertySetSchema





    properties
    end

    methods
        function obj=AnonPhysicalInterfaceElementSchema(elementWrapper,schemaFile,propertiesFile)


            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertySetSchema(elementWrapper,schemaFile,propertiesFile);

        end
        function schema=getSchema(obj)
            schema={};


            architecturePort=obj.elementWrapper.element;
            if~isempty(architecturePort.getPortInterface())&&architecturePort.getPortInterface().isAnonymous()
                prtInterface=architecturePort.getPortInterface();

                typeId='AInterfaceType';
                pieType=prtInterface.p_Type;
                templateSchema=obj.propertyParser.getEvaluatedProperty('AnonymousIntElemSchema',obj.elementWrapper);
                templateSchema.id=typeId;
                templateSchema.label=DAStudio.message('SystemArchitecture:PropertyInspector:Type');
                templateSchema.children=[];
                templateSchema.tooltip=strrep(pieType,'Connection: ','');
                templateSchema.renderMode=obj.getRenderMode(typeId);
                templateSchema.value=strrep(pieType,'Connection: ','');
                templateSchema.editable=false;
                templateSchema.enabled=~(obj.elementWrapper.isReference||obj.elementWrapper.isImpl||obj.elementWrapper.isViewPort);
                if obj.elementWrapper.isImpl
                    allowedTypes={};
                else
                    [~,allowedTypes]=systemcomposer.internal.getTypeAndAvailableTypes(prtInterface);
                end
                templateSchema.entries=allowedTypes;
                obj.propertyIDMap(typeId)=templateSchema;

                schema{end+1}=templateSchema;
            end
        end

        function renderMode=getRenderMode(~,propID)
            renderMode='editbox';
            if ismember(propID,{'AInterfaceType','AInterfaceComplexity'})
                renderMode='combobox';
            end
        end
    end
end



