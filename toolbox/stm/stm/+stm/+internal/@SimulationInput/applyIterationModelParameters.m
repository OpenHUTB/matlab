


function applyIterationModelParameters(this)
    parameters=this.RunTestCfg.testIteration.ModelParameter;
    if isempty(parameters)
        return;
    end

    parameters=addFieldsNeededForParameterReader(parameters);
    cache=this.applyVariablesAndBlockParameters(parameters);
    this.RunTestCfg.out.IterationModelParameters=cache;
end

function parameters=addFieldsNeededForParameterReader(parameters)
    bpType=stm.internal.VariableReader.BlockParameter.Type.char;
    mpType=stm.internal.VariableReader.ModelParameter.Type.char;
    blockParams=contains({parameters.System},'/');
    [parameters(blockParams).SourceType]=deal(bpType);
    [parameters(~blockParams).SourceType]=deal(mpType);
    [parameters.Source]=deal(parameters.System);
    [parameters.Name]=deal(parameters.Parameter);
    [parameters.ModelReference]=deal('');
end
