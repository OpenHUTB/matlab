function paramType=getParamTypeEnum(request)




    switch lower(request)
    case 'using'
        paramType=PARAM_USING;
    case 'authoring'
        paramType=PARAM_AUTHORING;
    otherwise

        configData=RunTimeModule_config;
        pm_error(configData.Error.UnknownParamTypeRequest_msgid);

    end


