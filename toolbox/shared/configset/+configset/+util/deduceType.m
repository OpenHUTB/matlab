function out=deduceType(val)





    if ischar(val)
        if strcmp(val,'on')||strcmp(val,'off')
            out='boolean';
        else
            out='string';
        end
    elseif isempty(val)
        out='object';
    elseif isscalar(val)
        if isnumeric(val)
            out='double';
        elseif isstruct(val)||ishandle(val)||iscell(val)||isobject(val)
            out='object';
        elseif islogical(val)
            out='boolean';
        else
            error(['unrecogonized type: ',class(val)]);
        end
    else
        out='object';
    end
