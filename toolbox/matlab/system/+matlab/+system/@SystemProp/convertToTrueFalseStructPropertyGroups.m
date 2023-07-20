function matlabGroups=convertToTrueFalseStructPropertyGroups(obj,matlabGroups)




    for n=1:numel(matlabGroups)
        propertyList=matlabGroups(n).PropertyList;

        propertyList=convertToStructFormatWithTrueFalse(obj,propertyList);

        matlabGroups(n).PropertyList=propertyList;
    end
end

function propertyList=convertToStructFormatWithTrueFalse(obj,propertyList)




    if isstruct(propertyList)
        propertyList=convertStructLogicals(obj,propertyList);
    else
        propertyList=convertCellToStruct(obj,propertyList);
    end
end

function propertyList=convertStructLogicals(obj,propertyList)

    names=fieldnames(propertyList);
    for n=1:numel(names)
        name=names{n};
        propertyInfo=findprop(obj,name);
        if~isempty(propertyInfo)
            propertyList.(name)=lookupValue(propertyInfo,propertyList.(name));
        end
    end
end

function propertyStruct=convertCellToStruct(obj,propertyList)


    propertyStruct=struct();
    for n=1:numel(propertyList)
        propertyName=propertyList{n};
        propertyInfo=findprop(obj,propertyName);
        if~isempty(propertyInfo)
            propertyStruct.(propertyName)=lookupValue(propertyInfo,obj.(propertyName));
        end
    end
end

function value=lookupValue(propertyInfo,value)
    if isa(propertyInfo,'matlab.system.CustomMetaProp')
        if propertyInfo.Logical||...
            (length(propertyInfo.Validation)==1&&...
            isa(propertyInfo.Validation.Size,'meta.FixedDimension')&&...
            isequal([propertyInfo.Validation.Size.Length],ones(1,2,'uint64'))&&...
            ~isempty(propertyInfo.Validation.Class)&&...
            strcmp(propertyInfo.Validation.Class.Name,'logical'))
            value=matlab.system.internal.TrueFalse.create(value);
        end
    end
end

