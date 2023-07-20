classdef StereotypePropertyWrapper<systemcomposer.internal.propertyInspector.wrappers.ProfileWrapper


    properties
    end

    methods
        function obj=StereotypePropertyWrapper(varargin)

            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ProfileWrapper(varargin{:});
            obj.schemaType='property';
        end

        function propName=getPropertyName(obj,~)
            propName=obj.element.getName;
        end

        function[type,entries]=getPropertyType(obj,~)
            prop=obj.element;
            entries=obj.getPropertyTypeEntries();
            struct;
            if(isa(prop.type,'systemcomposer.property.Enumeration'))
                typeName='enumeration';
            else
                typeName=prop.type.getName();
                if isempty(typeName)&&~isempty(prop.getBaseType)
                    typeName=prop.getBaseType;
                end
            end
            type=typeName;
        end

        function value=getPropertyOptions(obj,~)

            prop=obj.element;
            if isa(prop.type,'systemcomposer.property.Enumeration')
                value=prop.type.MATLABEnumName;
            else
                value='n/a';
            end
        end
        function enabled=isPropertyOptionsEnabled(obj,~)

            prop=obj.element;
            if isa(prop.type,'systemcomposer.property.Enumeration')
                enabled=true;
            else
                enabled=false;
            end
        end

        function value=getPropertyUnits(obj,~)

            value='n/a';
            prop=obj.element;
            switch class(prop.type)
            case{'systemcomposer.property.StringType',...
                'systemcomposer.property.StringArrayType',...
                'systemcomposer.property.BooleanType',...
                'systemcomposer.property.Enumeration'}

            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                value=prop.type.units;
            otherwise
                error('Unsupported property of type: %s',class(prop));
            end
        end

        function enabled=isPropertyUnitsEnabled(obj,~)
            prop=obj.element;
            enabled=false;
            switch class(prop.type)
            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                enabled=true;
            end
        end

        function[value,entries]=getPropertyDefaultValue(obj,~)

            prop=obj.element;
            entries={};
            switch class(prop.type)
            case 'systemcomposer.property.StringType'
                value=prop.defaultValue.expression;
            case 'systemcomposer.property.StringArrayType'
                value=prop.defaultValue.expression;
            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                val=prop.defaultValue.expression;
                if isempty(val)
                    val=num2str(prop.defaultValue.getValue);
                end
                value=val;
            case 'systemcomposer.property.BooleanType'
                value=double(prop.defaultValue.getValue);
            case 'systemcomposer.property.Enumeration'
                try


                    enumName=prop.type.MATLABEnumName;
                    if(~systemcomposer.property.Enumeration.isValidEnumerationName(enumName))
                        value='';







                        return;
                    else



                        valStrings=prop.type.getLiteralsAsStrings();
                        for v=1:length(valStrings)
                            name=valStrings(v);
                            if~strcmp(name,'stringArray')
                                entries{end+1}=struct('label',name,'value',name);
                            end
                        end
                        valString=char(prop.defaultValue.getValue);
                        if~strcmp(eval(prop.defaultValue.expression),valString)
                            storedExpression=eval(prop.defaultValue.expression);
                            entries{end+1}=struct('label',storedExpression,'value',storedExpression);
                            value=storedExpression;







                        else
                            value=valString;
                        end
                    end
                catch ME
                    value=eval(prop.defaultValue.expression);
                    entries{end+1}=struct('label',value,'value',value);







                end
            otherwise
                error('Unsupported property of type: %s',class(prop));
            end
        end
        function type=getPropertyDefaultValueType(obj,~)
            prop=obj.element;
            switch class(prop.type)
            case 'systemcomposer.property.StringType'
                type='TextField';
            case 'systemcomposer.property.StringArrayType'
                type='TextField';
            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                type='TextField';
            case 'systemcomposer.property.BooleanType'
                type='CheckBox';
            case 'systemcomposer.property.Enumeration'
                type='ComboBox';
            end
        end
        function editable=isPropertyDefaultEditable(obj,~)
            prop=obj.element;
            editable=false;
            switch class(prop.type)
            case{'systemcomposer.property.Enumeration','systemcomposer.property.BooleanType'}
                editable=true;
            end
        end
        function propTypeStrs=getPropertyTypeEntries(obj)


            propTypeStrs={};
            valueTypes=obj.profile.valueTypes;

            valueTypesArr=valueTypes.toArray;
            for v=1:length(valueTypesArr)
                name=valueTypesArr(v).getName();
                if~strcmp(name,'stringArray')


                    propTypeStrs{end+1}=struct('label',name,'value',name);
                end
            end
            propTypeStrs{end+1}=struct('label','enumeration','value','enumeration');
        end

        function min=getMin(obj,~)
            min=obj.element.getMin;
            if isempty(min)
                min='';
            end
        end

        function max=getMax(obj,~)
            max=obj.element.getMax;
            if isempty(max)
                max='';
            end
        end

        function entries=getMetaclassEntries(~)
            entries={...
            '<all>',...
'Component'...
            ,'Port',...
            'Connector',...
'Interface'...
            };
            if slfeature('SoftwareModeling')>0
                entries{end+1}='Function';
                entries{end+1}='Task';
            end
        end

    end
end





