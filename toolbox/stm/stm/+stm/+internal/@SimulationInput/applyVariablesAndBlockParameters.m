


function cache=applyVariablesAndBlockParameters(this,parameters)
    simIn=this.RunTestCfg.SimulationInput;
    readers=stm.internal.VariableReader.getReader(parameters,this.RunTestCfg.modelToRun);


    bpMask=arrayfun(@(elem)isa(elem,'stm.internal.VariableReader.BlockParameter'),readers);
    blockParams=arrayfun(@getSimInProperty,readers(bpMask));
    simIn.BlockParameters=[simIn.BlockParameters,blockParams];
    blockParamCache=getCache(blockParams,parameters(bpMask));


    mpMask=arrayfun(@(elem)isa(elem,'stm.internal.VariableReader.ModelParameter'),readers);
    modelParameters=arrayfun(@getSimInProperty,readers(mpMask));
    simIn.ModelParameters=[simIn.ModelParameters,modelParameters];
    modelParamCache=getCache(modelParameters,parameters(mpMask));

    lastwarn("","");


    varMask=~(bpMask|mpMask);
    variables=arrayfun(@getSimInProperty,readers(varMask));


    warnMessage=lastwarn;
    if strlength(warnMessage)~=0
        this.RunTestCfg.addMessages({warnMessage},{false});
    end
    simIn.Variables=[simIn.Variables,variables];
    variableCache=getCache(variables,parameters(varMask));


    cache=[variableCache{:},blockParamCache{:},modelParamCache{:}];
    this.RunTestCfg.SimulationInput=simIn;
end

function cache=getCache(variables,params)
    if~isempty(variables)
        cache=arrayfun(@(variable,param)...
        {variable.Value;param.Id;getDisplayValue(variable.Value)},...
        variables,params,'UniformOutput',false);
    else
        cache=cell.empty;
    end
end

function displayValue=getDisplayValue(value)
    [~,displayValue]=stm.internal.util.getDisplayValue(value);
end
