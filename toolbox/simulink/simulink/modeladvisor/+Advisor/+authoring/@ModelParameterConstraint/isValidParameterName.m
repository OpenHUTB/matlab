function status=isValidParameterName(ParameterName)





    if nargin>0
        ParameterName=convertStringsToChars(ParameterName);
    end

    data=configset.internal.getConfigSetStaticData;
    status=data.isValidParam(ParameterName);
end

