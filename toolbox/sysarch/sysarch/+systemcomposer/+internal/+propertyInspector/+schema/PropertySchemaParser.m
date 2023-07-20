classdef PropertySchemaParser



    properties
        propertiesSchemaFile;
        propertyIDMap;
    end

    methods
        function obj=PropertySchemaParser(propertiesSchemaFile)



            obj.propertyIDMap=containers.Map('keytype','char','valuetype','any');
            obj.propertiesSchemaFile=propertiesSchemaFile;
            propertySet=jsondecode(fileread(propertiesSchemaFile)).propertySet;
            for itr=1:numel(propertySet)
                property=propertySet(itr);
                id=property.id;
                obj.propertyIDMap(id)=property;
            end
        end

        function property=getProperty(obj,propertyID)


            if ismember(propertyID,obj.propertyIDMap.keys)
                property=obj.propertyIDMap(propertyID);
            else
                property={};
            end
        end

        function label=getLabel(obj,propertyID,elemWrapper)
            label=obj.evaluate(propertyID,'label',elemWrapper);
        end
        function tooltip=getTooltip(obj,propertyID,elemWrapper)


            tooltip=obj.evaluate(propertyID,'tooltip',elemWrapper);
        end
        function value=getRenderMode(obj,propertyID,elemWrapper)


            value=obj.evaluate(propertyID,'renderMode',elemWrapper);
        end
        function value=getEnabled(obj,propertyID,elemWrapper)


            property=obj.propertyIDMap(propertyID);
            if ischar(property.enabled)
                value=obj.evaluate(propertyID,'enabled',elemWrapper);
            else
                value=property.enabled;
            end
        end
        function value=getEditable(obj,propertyID,elemWrapper)


            property=obj.propertyIDMap(propertyID);
            if ischar(property.editable)
                value=obj.evaluate(propertyID,'editable',elemWrapper);
            else
                value=property.editable;
            end
        end
        function value=getValue(obj,propertyID,elemWrapper)


            value=obj.evaluate(propertyID,'value',elemWrapper);
        end

        function value=evaluate(obj,propertyID,evalProperty,elemWrapper)


            property=obj.propertyIDMap(propertyID);
            propertyValue=property.(evalProperty);

            if contains(propertyValue,'@')

                if contains(propertyValue,'(')&&contains(propertyValue,')')
                    propertyValue=string(propertyValue);
                    fetchFunction=propertyValue.extractBefore("(");
                    functionValue=propertyValue.extractAfter("(");
                    functionValue=functionValue.extractBefore(")");
                    eval(['callBackFunction = ',char(fetchFunction),';'])
                    value=callBackFunction(eval(functionValue));
                else
                    eval(['callBackFunction = ',propertyValue,';'])
                    value=callBackFunction(elemWrapper);
                end
            else

                value=propertyValue;
            end
        end

        function property=getEvaluatedProperty(obj,propertyID,elemWrapper)


            property=obj.propertyIDMap(propertyID);
            value=obj.getValue(propertyID,elemWrapper);
            if isempty(value)
                getterFunction=property.getter;
                if contains(getterFunction,'@')

                    eval(['callBackFunction = ',getterFunction,';'])
                    [value,entries]=callBackFunction(elemWrapper);
                    if~isempty(entries)
                        property.value=value;
                        property.entries=entries;
                    else
                        property.value=value;
                        property.entries={};
                    end
                else

                    property.value='';
                end
            else
                property.value=value;
            end
            fields=fieldnames(property);
            for itr=1:numel(fields)
                field=fields{itr};
                if ischar(property.(field))&&~ismember(field,{'getter','setter','value'})
                    value=obj.evaluate(propertyID,field,elemWrapper);
                else
                    value=property.(field);
                end
                property.(field)=value;
            end
        end
    end
end

