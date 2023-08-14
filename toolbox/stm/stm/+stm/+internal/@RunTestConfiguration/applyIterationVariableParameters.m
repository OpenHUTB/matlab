function applyIterationVariableParameters(obj,simWatcher)




    if(~isempty(obj.testIteration)&&~isempty(obj.testIteration.VariableParameter))
        iterationWrapper=stm.internal.util.TestIterationWrapper;
        poWrapper=stm.internal.Parameters.ParameterOverrideWrapper;

        variableParameter=iterationWrapper.preprocessIterationVariableParameters(obj.testIteration.VariableParameter,...
        obj.modelToRun);

        [overridesCache,originalValues,hModelWorkspace,dataDictionaryStates,...
        modelWorkspaceDirtyState,errors]=...
        poWrapper.overrideParameters(obj.modelToRun,variableParameter,true);

        simWatcher.cleanupIteration.VariableParameters.modelToRun=obj.modelToRun;
        simWatcher.cleanupIteration.VariableParameters.overridesStruct=variableParameter;
        simWatcher.cleanupIteration.VariableParameters.originalValues=originalValues;
        simWatcher.cleanupIteration.VariableParameters.hModelWorkspace=hModelWorkspace;
        simWatcher.cleanupIteration.VariableParameters.dataDictionaryStates=dataDictionaryStates;
        simWatcher.cleanupIteration.VariableParameters.modelWorkspaceDirtyState=modelWorkspaceDirtyState;

        obj.addMessages(errors.messages,errors.errorOrLog);
        obj.out.IterationVariableParameters=overridesCache;
    end
end