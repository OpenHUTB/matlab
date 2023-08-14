function value=resolveParameterObjectValue(parameterObject,parameterName,context)





    value=parameterObject.Value;

    if~(isnumeric(value)||isstruct(value))
        value=slResolve(parameterName,context,'expression','startUnderMask');
    end

end

