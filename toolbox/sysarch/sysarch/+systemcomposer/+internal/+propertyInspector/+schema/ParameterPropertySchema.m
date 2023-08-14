classdef ParameterPropertySchema<systemcomposer.internal.propertyInspector.schema.PropertySetSchema




    properties
ElementImpl
    end

    methods

        function obj=ParameterPropertySchema(elementWrapper,schemaFile,propertiesFile)

            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertySetSchema(elementWrapper,schemaFile,propertiesFile);
            obj.ElementImpl=elementWrapper.element;
        end

        function schema=getSchema(obj)
            schema={};

            paramNames=obj.ElementImpl.getParameterNames;
            if isempty(paramNames)
                propertyID=strcat('Parameters:','NoParametersDefined');
                templatePropertySchema.id=propertyID;
                noPropLabel=DAStudio.message('SystemArchitecture:PropertyInspector:NoParametersDefined');


                templatePropertySchema.label=strrep(strrep(noPropLabel,'<',''),'>','');
                templatePropertySchema.value='';
                templatePropertySchema.renderMode='none';
                templatePropertySchema.enabled=false;
                templatePropertySchema.editable=false;
                templatePropertySchema.children=[];
                obj.propertyIDMap(propertyID)=templatePropertySchema;
                templatePropertySchema={templatePropertySchema};
            else
                for cnt=1:numel(paramNames)
                    pName=paramNames{cnt};
                    templatePropertySchema{cnt}.id=pName;%#ok<*AGROW> 
                    templatePropertySchema{cnt}.label=pName;
                    templatePropertySchema{cnt}.children=[];
                    templatePropertySchema{cnt}.enabled=true;
                    templatePropertySchema{cnt}.editable=~obj.isInAllocationContext();
                    templatePropertySchema{cnt}.tooltip=pName;
                    templatePropertySchema{cnt}.renderMode=obj.getRenderMode(pName);
                    [value,entries]=obj.getPropertyValue(pName);
                    templatePropertySchema{cnt}.value=value;
                    templatePropertySchema{cnt}.setter='@setParameterValue';
                    templatePropertySchema{cnt}.entries=entries;
                    obj.propertyIDMap(pName)=templatePropertySchema{cnt};
                end
            end
            schema=templatePropertySchema;
        end

        function rendermode=getRenderMode(obj,paramName)

            paramUsage=obj.ElementImpl.getParameter(paramName);

            if isempty(paramUsage)
                paramDef=obj.ElementImpl.getParameterDefinition(paramName);
            else
                paramDef=paramUsage.definition;
            end

            if isempty(paramDef)
                rendermode='editbox';
                return;
            elseif~isempty(paramDef)
                switch class(paramDef.type)
                case 'systemcomposer.property.BooleanType'
                    rendermode='checkbox';
                case{'systemcomposer.property.StringType',...
                    'systemcomposer.property.StringArrayType'}
                    rendermode='editbox';
                case{'systemcomposer.property.FloatType',...
                    'systemcomposer.property.IntegerType'}
                    paramValStruct=obj.ElementImpl.getParamVal(paramName);
                    paramUnits=paramValStruct.units;
                    if isempty(paramUnits)
                        paramUnits=paramDef.ownedType.units;
                    end
                    rendermode='dualedit';
                case 'systemcomposer.property.Enumeration'
                    rendermode='combobox';
                otherwise

                end
            end
        end

        function result=isInAllocationContext(obj,~)
            if strcmp(obj.schemaFile,'AllocationEditorPropertyInspector.json')
                result=true;
            else
                result=false;
            end
        end

        function toolTip=getTooltip(~,paramName)
            toolTip=paramName;
        end


        function[value,entries]=getPropertyValue(obj,paramName)
            [value,entries]=obj.elementWrapper.getParameterValue(paramName);
        end

    end

end