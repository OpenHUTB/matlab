function applyParameterOverrides(this)


    if isempty(this.RunTestCfg.testSettings.parameterOverrides)
        return;
    end

    msg=message('stm:Execution:ReadingParameters').getString;
    if~isempty(this.SimIn.IterationName)
        msg=[this.SimIn.IterationName,newline,msg];
    end
    stm.internal.Spinner.updateTestCaseSpinnerLabel(this.SimIn.TestCaseId,msg);
    [params,success]=getParameterOverrides(this.RunTestCfg,this.SimWatcher);
    if isempty(params)||~success
        return;
    end

    cache=this.applyVariablesAndBlockParameters(params);
    this.RunTestCfg.out.OverridesCache=cache;
end

function[params,success]=getParameterOverrides(runTestConfig,simWatcher)
    success=runTestConfig.getParameterOverrideDetails(simWatcher);
    params=runTestConfig.testSettings.parameterOverrides.OverridesStruct;
    [params.Id]=deal(params.NamedParamId);
end
