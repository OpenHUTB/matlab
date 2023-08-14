
function[details]=getPropertyTypeDetails(this)

    details=struct();
    ps=this.p_PropertySets.toArray;
    for p=1:numel(ps)
        properties=ps(p).properties.toArray;
        setDetails=struct();
        for pi=1:numel(properties)
            property=properties(pi).propertyDef;

            if isa(property.type,'systemcomposer.property.StringType')
                detail=[];

            elseif isa(property.type,'systemcomposer.property.Enumeration')
                literals=property.type.getLiteralsAsStrings;
                litDef={};
                for li=1:numel(literals)
                    litDef{end+1}=struct('value',li-1,'literal',literals(li));
                end
                detail=struct('kind','enumeration');
                detail.enumName=property.type.MATLABEnumName;
                detail.literals=litDef;
            elseif isa(property.type,'systemcomposer.property.RealType')
                if isempty(property.type.minValue)
                    min=[];
                else
                    min=property.type.minValue;
                end
                if isempty(property.type.maxValue)
                    max=[];
                else
                    max=property.type.maxValue;
                end
                if isa(property.type,'systemcomposer.property.FloatType')
                    detail=struct('kind','real','units',property.type.units,...
                    'min',min,'max',max);
                else
                    detail=struct('kind','integer','units',property.type.units,...
                    'min',min,'max',max);
                end
            elseif isa(property.type,'systemcomposer.property.BooleanType')
                detail=struct('kind','boolean');

            else
                detail=[];
            end
            if~isempty(detail)
                setDetails.(property.getName)=detail;
            end
        end
        if~isempty(fields(setDetails))
            proto=ps(p).propertySet.prototype;
            details.(proto.profile.getName).(proto.getName)=setDetails;
        end
    end
end

