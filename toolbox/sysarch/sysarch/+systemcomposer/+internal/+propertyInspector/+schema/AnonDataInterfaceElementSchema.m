classdef AnonDataInterfaceElementSchema<systemcomposer.internal.propertyInspector.schema.PropertySetSchema





    properties
    end

    methods
        function obj=AnonDataInterfaceElementSchema(elementWrapper,schemaFile,propertiesFile)


            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertySetSchema(elementWrapper,schemaFile,propertiesFile);

        end
        function schema=getSchema(obj)
            schema={};


            architecturePort=obj.elementWrapper.element;
            if~isempty(architecturePort.getPortInterface())&&architecturePort.getPortInterface().isAnonymous()&&...
                ~isa(architecturePort.getPortInterface(),'systemcomposer.architecture.model.interface.CompositeDataInterface')
                prtInterface=architecturePort.getPortInterface();

                typeId='AInterfaceType';
                pieType=prtInterface.p_Type;
                templateSchema=obj.propertyParser.getEvaluatedProperty('AnonymousIntElemSchema',obj.elementWrapper);
                templateSchema.id=typeId;
                templateSchema.label=DAStudio.message('SystemArchitecture:PropertyInspector:Type');
                templateSchema.children=[];
                templateSchema.tooltip=pieType;
                templateSchema.renderMode=obj.getRenderMode(typeId);
                templateSchema.value=pieType;
                templateSchema.editable=false;
                templateSchema.enabled=~(obj.elementWrapper.isReference||obj.elementWrapper.isImpl||obj.elementWrapper.isViewPort);
                pieType=pieType(~isspace(pieType));
                if(startsWith(pieType,'Bus:'))
                    isBusType=true;
                else
                    isBusType=false;
                end
                if obj.elementWrapper.isImpl
                    allowedTypes={};
                else
                    [~,allowedTypes]=systemcomposer.internal.getTypeAndAvailableTypes(prtInterface);
                end
                templateSchema.entries=allowedTypes;
                obj.propertyIDMap(typeId)=templateSchema;

                schema{end+1}=templateSchema;

                dimID='AInterfaceDim';
                templateSchema=obj.propertyParser.getEvaluatedProperty('AnonymousIntElemSchema',obj.elementWrapper);
                templateSchema.id=dimID;
                templateSchema.label=DAStudio.message('SystemArchitecture:PropertyInspector:Dimensions');
                templateSchema.children=[];
                templateSchema.renderMode=obj.getRenderMode(dimID);
                templateSchema.value=prtInterface.p_Dimensions;
                templateSchema.tooltip=prtInterface.p_Dimensions;
                templateSchema.editable=true;
                templateSchema.enabled=~(isBusType||obj.elementWrapper.isReference||obj.elementWrapper.isImpl||obj.elementWrapper.isViewPort);
                obj.propertyIDMap(dimID)=templateSchema;

                schema{end+1}=templateSchema;

                unitId='AInterfaceUnit';
                templateSchema=obj.propertyParser.getEvaluatedProperty('AnonymousIntElemSchema',obj.elementWrapper);
                templateSchema.id=unitId;
                templateSchema.label=DAStudio.message('SystemArchitecture:PropertyInspector:Units');
                templateSchema.children=[];
                templateSchema.renderMode=obj.getRenderMode(unitId);
                templateSchema.value=prtInterface.p_Units;
                templateSchema.tooltip=prtInterface.p_Units;
                templateSchema.editable=true;
                templateSchema.enabled=~(isBusType||obj.elementWrapper.isReference||obj.elementWrapper.isImpl||obj.elementWrapper.isViewPort);
                obj.propertyIDMap(unitId)=templateSchema;

                schema{end+1}=templateSchema;

                complexityId='AInterfaceComplexity';
                templateSchema=obj.propertyParser.getEvaluatedProperty('AnonymousIntElemSchema',obj.elementWrapper);
                templateSchema.id=complexityId;
                templateSchema.label=DAStudio.message('SystemArchitecture:PropertyInspector:Complexity');
                templateSchema.children=[];
                templateSchema.renderMode=obj.getRenderMode(complexityId);
                templateSchema.value=prtInterface.p_Complexity;
                templateSchema.tooltip=prtInterface.p_Complexity;
                templateSchema.editable=false;
                templateSchema.entries=obj.elementWrapper.INTERFACE_COMPLEXITY;
                templateSchema.enabled=~(isBusType||obj.elementWrapper.isReference||obj.elementWrapper.isImpl||obj.elementWrapper.isViewPort);
                obj.propertyIDMap(complexityId)=templateSchema;

                schema{end+1}=templateSchema;


                minId='AInterfaceMin';
                templateSchema=obj.propertyParser.getEvaluatedProperty('AnonymousIntElemSchema',obj.elementWrapper);
                templateSchema.id=minId;
                templateSchema.label=DAStudio.message('SystemArchitecture:PropertyInspector:Minimum');
                templateSchema.children=[];
                templateSchema.renderMode=obj.getRenderMode(minId);
                templateSchema.value=prtInterface.p_Minimum;
                templateSchema.tooltip=prtInterface.p_Minimum;
                templateSchema.editable=true;
                templateSchema.enabled=~(isBusType||obj.elementWrapper.isReference||obj.elementWrapper.isImpl||obj.elementWrapper.isViewPort);
                obj.propertyIDMap(minId)=templateSchema;

                schema{end+1}=templateSchema;

                maxId='AInterfaceMax';
                templateSchema=obj.propertyParser.getEvaluatedProperty('AnonymousIntElemSchema',obj.elementWrapper);
                templateSchema.id=maxId;
                templateSchema.label=DAStudio.message('SystemArchitecture:PropertyInspector:Maximum');
                templateSchema.children=[];
                templateSchema.renderMode=obj.getRenderMode(maxId);
                templateSchema.value=prtInterface.p_Maximum;
                templateSchema.tooltip=prtInterface.p_Maximum;
                templateSchema.editable=true;
                templateSchema.enabled=~(isBusType||obj.elementWrapper.isReference||obj.elementWrapper.isImpl||obj.elementWrapper.isViewPort);
                obj.propertyIDMap(maxId)=templateSchema;

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



