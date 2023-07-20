function applyIterationSignalBuilderGroup(obj,simWatcher)



    if(~isempty(obj.testIteration)&&~isempty(obj.testIteration.SignalBuilderGroups))
        iterationWrapper=stm.internal.util.TestIterationWrapper;
        [overridesCache,originalSigBuilderParameters,tmpOut]=iterationWrapper.applyIterationSigBuilderGroups(obj.testIteration.SignalBuilderGroups);

        if(~isempty(tmpOut.messages))
            obj.addMessages(tmpOut.messages,tmpOut.errorOrLog);
        end
        obj.out.IterationSignalBuilderGroupsParameters=overridesCache;
        simWatcher.cleanupIteration.SignalBuilderGroups.orignalValues=originalSigBuilderParameters;
    end
end