function[str,converted]=mat2json(x)







    converted=true;
    if isempty(x)
        str='';
        return;
    end

    if ischar(x)
        str=x;
        return;
    end

    if isscalar(x)&&~iscell(x)
        if isnumeric(x)||islogical(x)
            if isnan(x)
                str='NaN';
            elseif isinf(x)
                str='Inf';
            else
                str=x;
            end
        elseif isobject(x)||isstruct(x)||ishandle(x)
            str='';
            converted=false;
        end
    else
        str='';
        converted=false;
    end


