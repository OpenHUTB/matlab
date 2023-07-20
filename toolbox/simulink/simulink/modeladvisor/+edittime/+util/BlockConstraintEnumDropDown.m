function values=BlockConstraintEnumDropDown(varargin)




    values=strings(0,0);
    isDefault=false;
    if numel(varargin)==2
        isDefault=true;
    end
    enums=varargin{1};
    enumValue=strsplit(enums,',');
    index=cellfun(@(x)~isempty(x),enumValue);
    enumValue=enumValue(index);
    if isDefault
        values(end+1)=enumValue{1};
        return
    end
    for i=1:numel(enumValue)
        values(end+1)=enumValue{i};
    end
end
