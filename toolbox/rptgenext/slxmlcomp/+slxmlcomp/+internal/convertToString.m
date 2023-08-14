function strval=convertToString(value)

















    try
        strval=attemptConversion(value);
    catch
        strval='';
    end

    if(~isscalar(string(strval)))
        strval='';
    end

end


function strval=attemptConversion(value)

    if ischar(value)||(isstring(value)&&isscalar(value))
        strval=char(value);
    elseif isnumeric(value)
        strval=mat2str(value);
    elseif islogical(value)
        if value
            strval='true';
        else
            strval='false';
        end
    elseif isstruct(value)
        strval='';
    elseif iscell(value)
        strval=char(value);
    else
        strval=value.toString();
    end

end
