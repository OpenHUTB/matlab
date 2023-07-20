function actionMode=utilCheckActionMode(mdladvObj,check)

    inputParams=mdladvObj.getInputParameters(check.getID);

    mode={'ManuallyNoValidate','ManuallyValidateAccuracy','ManuallyValidateTime','ManuallyValidateAll',...
    'AutoNoValidate','AutoValidateAccuracy','AutoValidateTime','AutoValidateAll'};

    auto=false;
    checkTime=false;
    checkAccuracy=false;

    for i=1:length(inputParams)
        name=inputParams{i}.Name;

        if strcmp(name,DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionMode'))
            if strcmp(inputParams{i}.Value,DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeAuto'))
                auto=true;
            end
            continue;
        end

        if strcmp(name,DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateTime'))
            checkTime=inputParams{i}.Value;
            continue;
        end

        if strcmp(name,DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateAccuracy'))
            checkAccuracy=inputParams{i}.Value;
            continue;
        end
    end

    i=auto*4+checkTime*2+checkAccuracy*1+1;
    actionMode=mode{i};








