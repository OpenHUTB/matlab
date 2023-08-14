classdef StereotypePropertySchema<systemcomposer.internal.propertyInspector.schema.PropertySetSchema





    properties
        propertySchemaID='AppliedStereotype';
        stereotypableElem;
    end

    methods

        function obj=StereotypePropertySchema(elementWrapper,schemaFile,propertiesFile)


            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertySetSchema(elementWrapper,schemaFile,propertiesFile);
        end

        function schema=getSchema(obj)
            schema={};

            obj.stereotypableElem=obj.elementWrapper.stereotypeElement;
            if~isempty(obj.stereotypableElem)
                stereotypes=obj.stereotypableElem.getPrototype;
            else
                stereotypes={};
            end

            for stereotype=stereotypes
                stereotypeName=stereotype.getName();
                stereotypeID=stereotype.fullyQualifiedName;
                templateSchema=obj.propertyParser.getEvaluatedProperty(obj.propertySchemaID,obj.elementWrapper);
                templateSchema.id=stereotypeID;
                templateSchema.label=stereotypeName;
                templateSchema.children=[];
                templateSchema.enabled=~obj.elementWrapper.isReference;
                templateSchema.tooltip=obj.getAppliedStereotypeTooltip(stereotype);
                templatePropertySchema=obj.propertyParser.getEvaluatedProperty('StereotypeProperty',obj.elementWrapper);
                if isempty(stereotype)

                    allPropUsageNames=obj.stereotypableElem.PropertySets.getByKey(stereotypeName).properties.keys;
                else
                    allPropUsageNames=obj.getAllPropertyNames(stereotype.fullyQualifiedName);
                end
                if isempty(allPropUsageNames)
                    propertyID=strcat(stereotypeID,':','NoPropertiesDefined');
                    templatePropertySchema.id=propertyID;
                    noPropLabel=DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions');


                    templatePropertySchema.label=strrep(strrep(noPropLabel,'<',''),'>','');
                    templatePropertySchema.renderMode='none';
                    templatePropertySchema.children=[];
                    templateSchema.children{end+1}=templatePropertySchema;
                    obj.propertyIDMap(propertyID)=templatePropertySchema;
                else
                    for propItr=1:numel(allPropUsageNames)
                        propertyName=allPropUsageNames{propItr};
                        propertyUsage=obj.getPropUsage(stereotype.fullyQualifiedName,propertyName);
                        propertyID=strcat(stereotypeID,':',propertyName);
                        templatePropertySchema.id=propertyID;
                        templatePropertySchema.label=propertyName;
                        templatePropertySchema.children=[];
                        templatePropertySchema.enabled=~obj.elementWrapper.isReference;
                        templatePropertySchema.tooltip=obj.getTooltip(propertyUsage);
                        templatePropertySchema.renderMode=obj.getRenderMode(propertyUsage);
                        [value,entries]=obj.getPropertyValue(propertyUsage);
                        templatePropertySchema.value=value;
                        templatePropertySchema.entries=entries;
                        templatePropertySchema.editable=obj.isEditable(propertyUsage);
                        templatePropertySchema.setter='@setPropertyValue';
                        templateSchema.children{end+1}=templatePropertySchema;
                        obj.propertyIDMap(propertyID)=templatePropertySchema;
                    end
                end
                obj.propertyIDMap(stereotypeID)=templateSchema;
                schema{end+1}=templateSchema;%#ok<AGROW>
            end
        end

        function rendermode=getRenderMode(obj,propertyUsage)
            if isempty(propertyUsage.propertyDef)
                rendermode='editbox';
                return;
            else
                switch class(propertyUsage.propertyDef.type)
                case 'systemcomposer.property.BooleanType'
                    rendermode='checkbox';
                case{'systemcomposer.property.StringType',...
                    'systemcomposer.property.StringArrayType'}
                    rendermode='editbox';
                case{'systemcomposer.property.FloatType',...
                    'systemcomposer.property.IntegerType'}
                    val=obj.stereotypableElem.getPropVal([propertyUsage.propertySet.getName,'.',propertyUsage.getName]);
                    propUnits=val.units;
                    if isempty(propUnits)
                        rendermode='dualedit';
                    else
                        rendermode='dualeditcombo';
                    end
                case 'systemcomposer.property.Enumeration'
                    rendermode='combobox';
                otherwise

                end
            end
        end

        function tooltip=getAppliedStereotypeTooltip(~,stereotype)
            tooltip={DAStudio.message('SystemArchitecture:PropertyInspector:RemoveStereo',stereotype.fullyQualifiedName),...
            DAStudio.message('SystemArchitecture:PropertyInspector:MakeDefault')};
        end


        function enabled=isEditable(~,~)
            enabled=true;
        end
        function toolTip=getTooltip(obj,propertyUsage)
            propFQN=[propertyUsage.propertySet.getName,'.',propertyUsage.getName];
            toolTip=propFQN;
            if obj.stereotypableElem.isPropValDefault(propFQN)
                toolTip=[toolTip,' ',DAStudio.message('SystemArchitecture:PropertyInspector:DefaultLabel')];
            end
        end

        function[value,entries]=getPropertyValue(obj,propUsg)
            entries={};
            propFQN=[propUsg.propertySet.getName,'.',propUsg.getName];
            val=obj.stereotypableElem.getPropVal(propFQN);
            if isempty(propUsg.propertyDef)
                propVal=val.expression;
                propUnits=val.units;

            else
                switch class(propUsg.propertyDef.type)
                case 'systemcomposer.property.BooleanType'
                    propVal=val.expression;
                    propUnits='';
                case{'systemcomposer.property.StringType',...
                    'systemcomposer.property.StringArrayType'}
                    propVal=val.expression;
                    propUnits='';
                case{'systemcomposer.property.FloatType',...
                    'systemcomposer.property.IntegerType'}
                    propVal=val.expression;
                    propUnits=val.units;
                    if~isempty(propUnits)
                        compatibleUnits=propUsg.getSimilarUnits();
                        if isempty(compatibleUnits)


                            compatibleUnits={propUsg.propertyDef.type.units};
                        end
                        entries=compatibleUnits;
                    end
                case 'systemcomposer.property.Enumeration'
                    try
                        enumVal=obj.stereotypableElem.getPropValObject(propFQN).getValue;
                        propVal=char(enumVal);
                        entries=propUsg.propertyDef.type.getLiteralsAsStrings;
                    catch ME
                        if(strcmp(ME.identifier,'SystemArchitecture:Property:InvalidEnumPropValue'))
                            propVal=eval(val.expression);
                        else
                            rethrow(ME)
                        end
                    end
                    propUnits='';
                otherwise
                end
            end
            if~isempty(propUnits)
                value=[propVal,' ',propUnits];
            else
                value=propVal;
            end
        end


        function PU=getPropUsage(obj,protoName,propUsgName)



            if isa(obj.stereotypableElem,'systemcomposer.architecture.model.design.BaseComponent')
                obj.stereotypableElem=obj.stereotypableElem.getArchitecture;
            end
            psu=obj.stereotypableElem.getPropertySet(protoName);
            PU=psu.getPropertyUsage(propUsgName);

            if isempty(PU)


                protoParent=psu.p_Parent;
                if~isempty(protoParent)
                    PU=obj.getPropUsage(protoParent.getName,propUsgName);
                end
            end
        end

        function propertyNames=getAllPropertyNames(obj,prototypeName)

            propSetUsage=obj.stereotypableElem.getPropertySet(prototypeName);
            propertyNames={};

            if isempty(propSetUsage)
                return;
            end
            while~isempty(propSetUsage)
                propUsages=propSetUsage.properties.toArray;
                foundProps={};
                missingProps={};

                for propUsage=propUsages
                    propDef=propUsage.propertyDef;
                    if~isempty(propDef)&&strcmp(propDef.getName,propUsage.getName)
                        originalIdx=propDef.p_Index;
                        foundProps{originalIdx+1}=propDef.getName;%#ok<AGROW>, % prop defs are 0-indexed
                    else

                        missingProps{end+1}=propUsage.getName;%#ok<AGROW>
                    end
                end

                emptyIdx=cellfun(@isempty,foundProps);
                if any(emptyIdx)



                    foundProps(emptyIdx)=[];%#ok<AGROW>
                end

                propertyNames=horzcat(propertyNames,foundProps,missingProps);%#ok<AGROW>

                propSetUsage=propSetUsage.p_Parent;
            end
        end
    end
end


