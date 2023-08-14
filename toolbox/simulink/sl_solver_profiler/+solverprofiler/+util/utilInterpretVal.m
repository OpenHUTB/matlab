function value=utilInterpretVal(str)
    try
        value=eval(str);
    catch
        value=evalin('base',str);
    end

end