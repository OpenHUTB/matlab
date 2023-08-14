function dType=isParamOfBusType(paramName)

    dType=[];
    try
        paramProps=evalinGlobalScope(bdroot,paramName);
        dataType=paramProps.DataType;
        if strfind(dataType,'Bus: ')==1&&isa(evalinGlobalScope(bdroot,dataType(6:end)),'Simulink.Bus')
            dType=dataType(6:end);
        end
    catch
    end
end
