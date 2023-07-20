

function setupSignalBuilder(runCfg,simInStruct,simWatcher)




    if isempty(simInStruct.SigBuilderGroupName)&&~isempty(simInStruct.TestIteration)&&...
        ~isempty(simInStruct.TestIteration.TestParameter)&&~isempty(simInStruct.TestIteration.TestParameter.SigBuilderGroupName)
        simInStruct.SigBuilderGroupName=simInStruct.TestIteration.TestParameter.SigBuilderGroupName;
    end
    if~isempty(simInStruct.SigBuilderGroupName)
        simWatcher.signalBuilderBlock=stm.internal.blocks.SignalBuilderBlock(runCfg.modelToRun);
        if~isempty(simWatcher.signalBuilderBlock.handle)
            override=simInStruct.SigBuilderGroupName;
            if~isempty(simInStruct.TestIteration.TestParameter.SigBuilderGroupName)
                override=simInStruct.TestIteration.TestParameter.SigBuilderGroupName;
            end
            [handle,idx]=simWatcher.signalBuilderBlock.setActiveComponent(override);
            simWatcher.cleanupIteration.SignalBuilder=handle;
            simWatcher.cleanupIteration.SigBuilderIndex=idx;
        end
    else
        runCfg.applyIterationSignalBuilderGroup(simWatcher);
    end
end
