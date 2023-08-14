function applyIterationModelParameters(obj,simWatcher)



    iterationWrapper=stm.internal.util.TestIterationWrapper;
    if(~isempty(obj.testIteration)&&~isempty(obj.testIteration.ModelParameter))
        [overridesCache,originalModelParameters,tmpOut]=iterationWrapper.applyIterationModelParameters(obj.testIteration.ModelParameter);
        if(isempty(tmpOut.messages))
            obj.out.IterationModelParameters=overridesCache;
            simWatcher.cleanupIteration.ModelParameters.originalValues=originalModelParameters;
        else
            obj.addMessages(tmpOut.messages,tmpOut.errorOrLog);
        end
    end
end