function assignUploadedParameter(name,value,isSimulinkParameter,model)




    dataAccessor=Simulink.data.DataAccessor.createForExternalData(model);
    paramId=dataAccessor.name2UniqueID(name);

    if isSimulinkParameter
        paramValue=dataAccessor.getVariable(paramId);
        paramValue.Value=value;
    else
        paramValue=value;
    end

    dataAccessor.updateVariable(paramId,paramValue);
end
