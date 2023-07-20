function stfRegisterEnum(valIn)









    if~isempty(valIn)&isfield(valIn,'Name')&...
        isfield(valIn,'Strings')&isfield(valIn,'Values')
        for i=1:length(valIn)
            name=valIn(i).Name;
            strs=valIn(i).Strings;
            vals=valIn(i).Values;
            if~isempty(name)&~isempty(strs)&~isempty(vals)
                p=findtype(name);
                if isempty(p)
                    schema.EnumType(name,strs,vals);
                end
            end
        end
    end
