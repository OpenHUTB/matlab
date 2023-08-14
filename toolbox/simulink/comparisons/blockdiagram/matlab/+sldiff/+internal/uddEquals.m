function bool=uddEquals(first,second,filteredFields)




    a=struct(first);
    b=struct(second);

    bool=structEquals(a,b,filteredFields);
end

function bool=equalsRecursive(a,b,filteredFields)
    if isnumeric(a)||isnumeric(b)||islogical(a)||islogical(b)||...
        ischar(a)||ischar(b)||isstring(a)||isstring(b)
        bool=isequal(a,b);
        return
    end

    if iscell(a)&&iscell(b)
        bool=cellEquals(a,b,filteredFields);
        return
    end

    if numel(a)>1&&numel(b)>1
        bool=arrayEquals(a,b,filteredFields);
        return
    end

    if numel(a)==1&&numel(b)==1
        bool=structEquals(struct(a),struct(b),filteredFields);
        return
    end

    bool=isequal(a,b);
    return
end

function bool=structEquals(a,b,filteredFields)
    fields=fieldnames(a);

    if~isequal(fields,fieldnames(b))
        bool=false;
        return
    end

    for ii=1:length(fields)
        field=fields{ii};
        if~any(strcmp(field,filteredFields))&&...
            ~equalsRecursive(a.(field),b.(field),filteredFields)
            bool=false;
            return
        end
    end

    bool=true;
end

function bool=cellEquals(a,b,filteredFields)
    if~isequal(size(a),size(b))
        bool=false;
        return;
    end

    elementEquals=@(x,y)equalsRecursive(x,y,filteredFields);
    bool=all(cellfun(elementEquals,a,b),'all');
end

function bool=arrayEquals(a,b,filteredFields)
    if~isequal(size(a),size(b))
        bool=false;
        return;
    end

    elementEquals=@(x,y)equalsRecursive(x,y,filteredFields);
    bool=all(arrayfun(elementEquals,a,b),'all');
end
