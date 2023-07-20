classdef AnalysisObject<handle



    properties
        model=[];
        mfObject=[];
    end

    methods
        function res=empty(obj)
            res=isempty(obj.mfObject);
        end
        function obj=AnalysisObject(model)
            obj.model=model;
        end

        function psu=usePropertySet(obj,dest,set,name)
            model=obj.model;
            psu=systemcomposer.property.PropertySetUsage(model);
            psu.Name=name;
            psu.propertySet=set;

            props=set.ownedPropertyDefinitions.toArray;

            for p=1:length(props)
                prop=props(p);
                pu=systemcomposer.property.PropertyUsage(model);
                psu.ownedPropertyUsages.add(pu);
                pu.Name=prop.Name;
                pu.propertyDef=prop;
                pu.initialValue=obj.copyValueSpecification(prop.defaultValue);
            end

            dest.ownedPropertySetUsages.add(psu);
        end

        function copy=copyValueSpecification(obj,original)
            if isa(original,'systemcomposer.property.LiteralReal')
                copy=systemcomposer.property.LiteralReal(obj.model);
            elseif isa(original,'systemcomposer.property.LiteralBoolean')
                copy=systemcomposer.property.LiteralBoolean(obj.model);
            end
            copy.value=original.value;
        end

        function vs=convertMxArrayToValueSpecification(obj,value)

            switch class(value)
            case 'double'
                vs=systemcomposer.property.LiteralReal(obj.model);
            case 'logical'
                vs=systemcomposer.property.LiteralBoolean(obj.model);
            otherwise
                vs=systemcomposer.property.LiteralReal(obj.model);
            end
            vs.value=value;
        end

        function value=convertValueSpecificationToMxArray(obj,vs)

            if isa(vs,'systemcomposer.property.LiteralReal')||...
                isa(vs,'systemcomposer.property.LiteralBoolean')
                value=vs.value;
            end
        end

        function valueType=createValueType(obj,typeName)

            switch typeName
            case 'Real'
                valueType=systemcomposer.property.RealType(obj.model);
            case 'Boolean'
                valueType=systemcomposer.property.BooleanType(obj.model);
            otherwise
                valueType=systemcomposer.property.RealType(obj.model);
            end
        end

    end
end

