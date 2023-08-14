function applyParameterOverrides(obj,simWatcher)


    if~isfield(obj.testSettings.parameterOverrides,'parameterSetId')
        return;
    end

    if~obj.getParameterOverrideDetails(simWatcher)
        return;
    end

    overridesStruct=obj.testSettings.parameterOverrides.OverridesStruct;
    if isstruct(overridesStruct)
        [overridesCache,originalValues,hModelWorkspace,dataDictionaryStates,...
        modelWorkspaceDirtyState,errors]=...
        stm.internal.Parameters.ParameterOverrideWrapper.overrideParameters(obj.modelToRun,overridesStruct,false);

        obj.out.OverridesCache=overridesCache;
        obj.addMessages(errors.messages,errors.errorOrLog);

        simWatcher.cleanupIteration.ParamOverrides.modelToRun=obj.modelToRun;
        simWatcher.cleanupIteration.ParamOverrides.originalValues=originalValues;
        simWatcher.cleanupIteration.ParamOverrides.overridesStruct=obj.testSettings.parameterOverrides.OverridesStruct;
        simWatcher.cleanupIteration.ParamOverrides.hModelWorkspace=hModelWorkspace;
        simWatcher.cleanupIteration.ParamOverrides.dataDictionaryStates=dataDictionaryStates;
        simWatcher.cleanupIteration.ParamOverrides.modelWorkspaceDirtyState=modelWorkspaceDirtyState;
    end
end
