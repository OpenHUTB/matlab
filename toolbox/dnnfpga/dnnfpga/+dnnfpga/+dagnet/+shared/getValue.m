



function value=getValue(label,object,defaultValue)

    errorIfUndefined=false;

    if nargin<3
        errorIfUndefined=true;
    end

    if errorIfUndefined
        value=object.(label);
    else
        try
            value=object.(label);
        catch
            value=defaultValue;
        end
    end

end

