function value=utilGetScalarValue(str)
    try

        value=eval(str);

        if~isnumeric(value)
            try
                value=evalin('base',str);
            catch
                value=str;
            end
        end
    catch
        try
            value=evalin('base',str);
        catch
            value=str;
        end
    end
end