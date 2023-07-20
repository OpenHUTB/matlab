function setModelParam(mdlName,paramName,paramValue)




    model=bdroot(mdlName);

    mdlParams=slplc.utils.modelParams();
    [isValidParamName,locInMdlParamNames]=ismember(paramName,{mdlParams.name});

    if~isValidParamName
        diagStr=evalc('disp({mdlParams.name}'')');
        error('Invalid ladder logic model parameters %s. Currently supported parameters are:\n\n%s\n\n',...
        paramName,diagStr);
    end

    valueOption=mdlParams(locInMdlParamNames).values;
    if~strcmp(paramName,'SampleTime')&&~ismember(lower(paramValue),valueOption)
        diagStr=evalc('disp(valueOption)');
        error('Invalid ladder logic model parameter value %s. The value should be one of:\n\n%s\n\n',...
        paramValue,diagStr);
    end

    try
        set_param(model,paramName,paramValue);
    catch
        add_param(model,paramName,paramValue);
    end

    switch paramName
    case 'PLCLadderLogicDebug'
        errorSimSetting(paramName,model);
        if strcmpi(paramValue,'off')
            slplc.api.setModelParam(model,'PLCLadderLogicAnimation','off');
            slplc.api.setModelParam(model,'PLCLadderLogicDataShow','off');
            slplc.api.setFastSim(model,'on');
        else
            slplc.api.setFastSim(model,'off');
        end
    case 'PLCLadderLogicPrescan'
        errorSimSetting(paramName,model);
        slplc.api.setPrescan(model,paramValue);
    case 'PLCLadderLogicSLDVPreprocessing'
        errorSimSetting(paramName,model);
        if strcmpi(paramValue,'on')
            slplc.api.setFastSim(model,'on');
            slplc.api.setPrescan(model,'off');
        else
            slplc.api.setPrescan(model,'on');
        end
        slplc.api.setSLDV(model,paramValue);
    case 'PLCCallbacks'
        errorSimSetting(paramName,model);
        slplc.api.setCallbacks(model,paramValue);
    case 'SampleTime'
        errorSimSetting(paramName,model);
        slplc.api.setSampleTime(model,paramValue);
    end

end

function errorSimSetting(paramName,model)
    simStatus=get_param(model,'SimulationStatus');
    if~strcmpi(simStatus,'stopped')
        error('slplc:InvalidModelSetting',...
        'Cannot set %s value while simulation is running for model %s',paramName,model);
    end
end
