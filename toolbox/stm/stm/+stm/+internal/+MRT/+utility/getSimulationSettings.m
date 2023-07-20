function[runcfg,simInput]=getSimulationSettings(testId,iterationId,simIndex)





    if(iterationId==0)
        simInput=stm.internal.getSimulationSetting(testId,simIndex);
    else
        simInput=stm.internal.getSimulationSetting(iterationId,simIndex);
    end


    simInput.IsRunningOnCurrentRelease=false;

    runcfg=stm.internal.MRT.utility.RunTestConfiguration();
    runcfg.runningOnPCT=true;

    warnID='MATLAB:structOnObject';
    prev_state=warning('query',warnID);
    warning('off',warnID);
    oc=onCleanup(@()warning(prev_state.state,warnID));
    simInput.CoverageSettings=struct(stm.internal.Coverage.getCoverageSettings(...
    simInput.CallingFunction,simInput.TestCaseId));

    modelToRun=resolveModelToRun(simInput.Model,simInput.HarnessName);
    simInput.assessmentsLoggingInfo=...
    stm.internal.MRT.utility.getAssessmentsLoggingInfo(...
    simInput.TestCaseId,modelToRun,...
    simIndex+1);

    try
        if(stm.internal.MRT.utility.RunTestConfiguration.checkIfValidSimInput(simInput))
            if(~runcfg.processTestCaseSettings(simInput))
                return;
            end
        else
            runcfg.addMessages({getString(message('stm:general:InvalidSimInputStructure'))},{true});
        end
    catch me
        [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
        runcfg.addMessages(tempErrors,tempErrorOrLog);
    end
end

function modelToRun=resolveModelToRun(model,harness)



    if isempty(model)
        modelToRun=model;
        return;
    end
    if~bdIsLoaded(model)

        load_system(model);
        ocp=onCleanup(@()close_system(model));
    end
    modelToRun=stm.internal.util.resolveModelToRun(model,harness);
end