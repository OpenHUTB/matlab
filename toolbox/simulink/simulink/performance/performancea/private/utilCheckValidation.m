function[validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,check)


    validateTime=false;
    validateAccuracy=false;

    inputParams=mdladvObj.getInputParameters(check.getID);

    for i=1:length(inputParams)
        name=inputParams{i}.Name;

        if strcmp(name,DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateTime'))
            value=inputParams{i}.Value;
            validateTime=value;
            continue;
        end

        if strcmp(name,DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateAccuracy'))
            value=inputParams{i}.Value;
            validateAccuracy=value;
            continue;
        end

    end



