

function result=styleguide_jmaab_0742_logicalExpressions(str,variableNames,enableBit)
    result=true;
    if isempty(str)||isempty(variableNames)
        return;
    end

    if iscell(str)
        str=str{1};
    end

    res=cellfun(@(x)contains(str,x),variableNames);

    if~any(res)
        return;
    end


    if enableBit
        and_or='&&|\|\|';
    else


        and_or='&|\|';
    end

    pattern=['([!~=><]=|[><]|',and_or,')'];

    if isempty(regexp(str,pattern,'once'))
        result=false;
    end
end