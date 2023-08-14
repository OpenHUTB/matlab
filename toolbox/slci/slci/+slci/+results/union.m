






function op=union(stringSet1,stringSet2)
    if nargin>0
        if isstring(stringSet1)
            stringSet1=cellstr(stringSet1);
        end
    end

    if nargin>1
        stringSet2=convertStringsToChars(stringSet2);
    end

    assert(iscell(stringSet1),['First input argument to union must be a cell array']);
    if isa(stringSet2,'cell')
        if numel(stringSet2)==1
            op=addUnique(stringSet1,stringSet2{1});
        else
            op=union(stringSet1,stringSet2,'stable');
        end
    else
        op=addUnique(stringSet1,stringSet2);
    end
end

function stringSet=addUnique(stringSet,elem)
    if~any(strcmp(stringSet,elem))
        stringSet{end+1}=elem;
    end
end
