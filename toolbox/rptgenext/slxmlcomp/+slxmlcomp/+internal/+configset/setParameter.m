function setParameter(targetModelName,configSetName,parameterName,parameterValue)


    if(bdIsLibrary(targetModelName))
        librarySetParam(targetModelName,parameterName,parameterValue);
        return
    end

    modelSetParam(targetModelName,configSetName,parameterName,parameterValue);
end

function librarySetParam(modelName,parameterName,parameterValue)
    set_param(modelName,parameterName,parameterValue);
end

function modelSetParam(modelName,configSetName,parameterName,parameterValue)
    configSet=getConfigSet(modelName,configSetName);
    configSet.set_param(parameterName,parameterValue);
end
