function result=evalParam(param)
    if isa(param,'Simulink.Parameter')
        result=param.Value;
    else
        result=param;
    end
end