function tf=isPropertyChanged(obj,val1,val2)


    if isempty(val1)
        tf=true;
    else
        if iscell(val1)&&iscell(val2)
            if all(cellfun(@ischar,val1))&&all(cellfun(@ischar,val2))
                tf=any(~strcmpi(val1,val2));
            end

            if all(cellfun(@isnumeric,val1))&&all(cellfun(@isnumeric,val2))
                tf=~isequal(val1,val2);
            end
        elseif iscell(val1)&&~iscell(val2)
            if all(cellfun(@ischar,val1))&&ischar(val2)
                tf=any(~strcmpi(val1,val2));
            end
        elseif~iscell(val1)&&iscell(val2)
            if ischar(val1)&&all(cellfun(@ischar,val2))
                tf=any(~strcmpi(val1,val2));
            end

        elseif ischar(val1)||isstring(val1)
            tf=~(strcmpi(val1,val2)&&isa(val1,class(val2)));
        else
            tf=~isequal(val1,val2);
        end
    end


    if tf
        setHasStructureChanged(obj);
        parentObj=getParent(obj);
        while~isempty(parentObj)
            setHasStructureChanged(parentObj);
            parentObj=getParent(parentObj);
        end
    end

end