


function applyIterationVariableParameters(this)
    parameters=this.RunTestCfg.testIteration.VariableParameter;
    if isempty(parameters)
        return;
    end

    parameters=addFieldsNeededForVariableReader(parameters);
    cache=this.applyVariablesAndBlockParameters(parameters);
    this.RunTestCfg.out.IterationVariableParameters=cache;
end

function variables=addFieldsNeededForVariableReader(variables)
    isModelRef=getModelRefIdx(variables);

    [variables.ModelReference]=deal('');
    [variables(isModelRef).ModelReference]=variables(isModelRef).Source;
    [variables(isModelRef).Source]=deal('model workspace');
    loadModelsForMdlRefParams(variables(isModelRef));

    [variables.SourceType]=deal(variables.Source);
    [variables.IsDerived]=deal(~cellfun(@ischar,{variables.Value}));
    [variables.RuntimeValue]=deal(variables.Value);
    [variables.IsOverridingChar]=deal(false);
end


function loadModelsForMdlRefParams(variables)
    load_system({variables.ModelReference});
end

function isModelRef=getModelRefIdx(variables)
    sources={variables.Source};
    isBW=sources==stm.internal.VariableReader.BaseWorkspace.Type;
    isBP=stm.internal.VariableReader.BlockParameter.isBlockParameter(sources);
    isMP=sources==stm.internal.VariableReader.ModelParameter.Type;
    isDD=stm.internal.VariableReader.DataDictionary.isSldd(sources);
    isModelRef=~(isBW|isBP|isMP|isDD|{variables.Source}=="model workspace");
end
