classdef(Sealed,Hidden)DataTypesGroup<matlab.system.display.PropertyGroup




    methods(Static,Hidden)
        function hasDT=hasDataTypes(systemName)
            metaClassData=meta.class.fromName(systemName);
            hasDT=~isempty(metaClassData)&&...
            ~isempty(matlab.system.display.internal.DataTypesGroup.getDataTypePropertyList(metaClassData.PropertyList));
        end

        function flag=isDataTypeSetPropertyForCodegen(propName,mc)
            flag=false;




            metaProperties=mc.PropertyList;
            allPropNames={metaProperties.Name};
            setProp=metaProperties(strcmp(allPropNames,[propName,'Set']));
            if~isempty(setProp)&&setProp.HasDefault
                value=setProp.DefaultValue;
                flag=isa(value,'matlab.system.internal.DataTypeSet')&&~strcmp(value.Compatibility,'Legacy');
            end
        end

        function isDT=isDataTypeSetProperty(className,prop)
            if matlab.system.display.isSystem(className)
                metaClass=meta.class.fromName(className);
                dataTypeProperties=matlab.system.display.internal.DataTypesGroup.getDataTypePropertyList(metaClass.PropertyList);
                isDT=~ismember(prop,{'RoundingMethod','OverflowAction'})&&ismember(prop,dataTypeProperties);
            else
                isDT=false;
            end
        end

        function props=getDataTypePropertyList(metaProperties)

            allPropNames={metaProperties.Name};
            props={};


            for ind=1:numel(metaProperties)
                metaProperty=metaProperties(ind);
                propName=metaProperty.Name;


                if metaProperty.Hidden||(isa(metaProperty,'matlab.system.CustomMetaProp')&&~metaProperty.ConstrainedSet)
                    continue;
                end


                dataTypeSetProperty=metaProperties(strcmp(allPropNames,[propName,'Set']));
                if isempty(dataTypeSetProperty)||~dataTypeSetProperty.HasDefault
                    continue;
                end

                constrainedSet=dataTypeSetProperty.DefaultValue;
                if isa(constrainedSet,'matlab.system.internal.RoundingMethodSet')||isa(constrainedSet,'matlab.system.internal.OverflowActionSet')
                    props=[props,propName];%#ok<AGROW>
                elseif isa(constrainedSet,'matlab.system.internal.DataTypeSet')

                    valuePropertyName=constrainedSet.ValuePropertyName;
                    if~isempty(valuePropertyName)&&~any(strcmp(allPropNames,valuePropertyName))
                        error(message('MATLAB:system:UnknownValueProperty',valuePropertyName));
                    end

                    props=[props,propName];%#ok<AGROW>

                    if strcmp(constrainedSet.Compatibility,'Legacy')
                        customPropName=['Custom',propName];
                        customDataTypeProperty=metaProperties(strcmp(allPropNames,customPropName));
                        if~customDataTypeProperty.Hidden
                            props=[props,customPropName];%#ok<AGROW>
                        end
                    end

                end
            end
        end
    end

    methods
        function obj=DataTypesGroup(systemName,varargin)

            if~matlab.system.display.isSystem(systemName)
                error(message('MATLAB:system:unknownSystem',systemName));
            end


            defaultDescription=message('MATLAB:system:DataTypesGroupDefaultDescription').getString;


            p=inputParser;
            p.FunctionName='matlab.system.display.internal.DataTypesGroup';
            p.addParameter('Description',defaultDescription);
            p.parse(varargin{:});
            results=p.Results;


            obj.Title=message('MATLAB:system:DataTypesGroupDefaultTitle').getString;
            obj.TitleSource='Property';
            obj.Description=results.Description;
            metaClassData=meta.class.fromName(systemName);
            obj.PropertyList=matlab.system.display.internal.DataTypesGroup.getDataTypePropertyList(metaClassData.PropertyList);
        end
    end

    methods(Hidden)
        function properties=getDisplayProperties(obj,metaClassData)

            metaProperties=metaClassData.PropertyList;
            propList=obj.PropertyList;
            properties=matlab.system.display.internal.DataTypeProperty.empty;

            for propInd=1:numel(propList)
                prop=propList{propInd};

                if isa(prop,'matlab.system.display.internal.DataTypeProperty')
                    property=prop;
                    property=property.setAttributes(metaProperties);
                elseif isa(prop,'matlab.system.display.internal.Property')
                    error(message('MATLAB:system:DataTypesGroupInvalidProperty'));
                else
                    property=matlab.system.display.internal.DataTypeProperty(propList{propInd});
                    property=property.setAttributes(metaProperties);
                end

                properties(end+1)=property;%#ok<AGROW>
            end
        end
    end
end