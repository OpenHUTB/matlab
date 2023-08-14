function paramValue=getModelParam(mdlName,paramName)




    model=bdroot(mdlName);

    mdlParams=slplc.utils.modelParams();
    [isValidParamName,locInMdlParamNames]=ismember(paramName,{mdlParams.name});

    if~isValidParamName
        diagStr=evalc('disp({mdlParams.name}'')');
        error('Invalid ladder logic model parameters %s. Currently supported parameters are:\n\n%s\n\n',...
        paramName,diagStr);
    end

    defaultParamValues={mdlParams.defaultValue};
    defaultParamvalue=defaultParamValues{locInMdlParamNames};

    try
        paramValue=get_param(model,paramName);
    catch
        paramValue=defaultParamvalue;
    end

end
