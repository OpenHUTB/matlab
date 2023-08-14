function inputParam=utilGetInputParameter(inputParams,paramName)





    inputParam=[];
    for ii=1:length(inputParams)
        inParam=inputParams{ii};
        if strcmpi(inParam.Name,paramName)
            inputParam=inParam;
            return;
        end
    end

    if isempty(inputParam)
        error(message('hdlcoder:workflow:ParamNameMismatch',paramName));
    end
