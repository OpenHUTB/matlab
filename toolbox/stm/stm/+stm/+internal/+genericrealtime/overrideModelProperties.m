function out=overrideModelProperties(simInputs,simWatcher)


    modelToRun=simWatcher.modelToRun;
    out.messages={};
    out.errorOrLog={};
    out.IterationModelParameters=[];
    out.IterationSignalBuilderGroupsParameters=[];
    if(~isa(simWatcher.simModel,'stm.internal.util.SimulinkModel'))
        error(message('stm:general:InvalidModel',modelToRun));
    end


    simWatcher.cleanupTestCase.Dirty=get_param(modelToRun,'Dirty');


    if simInputs.OutputCtrlEnabled
        currSaveOutput=get_param(modelToRun,'SaveOutput');
        currSaveState=get_param(modelToRun,'SaveState');
        currSaveTime=get_param(modelToRun,'SaveTime');
        needSaveTime=false;
        if(simInputs.SaveOutput)
            set_param(modelToRun,'SaveOutput','on');
            needSaveTime=true;
        else
            set_param(modelToRun,'SaveOutput','off');
        end
        simWatcher.cleanupTestCase.SaveOutput=currSaveOutput;
        if(simInputs.SaveState)
            set_param(modelToRun,'SaveState','on');
            needSaveTime=true;
        else
            set_param(modelToRun,'SaveState','off');
        end
        simWatcher.cleanupTestCase.SaveState=currSaveState;


        if(strcmpi(currSaveTime,'off')&&needSaveTime)
            set_param(modelToRun,'SaveTime','on');
            simWatcher.cleanupTestCase.SaveTime=currSaveTime;
        end
    end

    iterationWrapper=stm.internal.util.TestIterationWrapper;


    if(~isempty(simInputs.TestIteration)&&~isempty(simInputs.TestIteration.ModelParameter))

        [overridesCache,originalModelParameters,tmpOut]=iterationWrapper.applyIterationModelParameters(simInputs.TestIteration.ModelParameter);

        out.messages=[out.messages,tmpOut.messages];
        out.errorOrLog=[out.errorOrLog,tmpOut.errorOrLog];
        if(isempty(tmpOut.messages))
            out.IterationModelParameters=overridesCache;
            simWatcher.cleanupIteration.ModelParameters.originalValues=originalModelParameters;
        end
    end


    if(simInputs.IsSigBuilderUsed)&&~isempty(simInputs.SigBuilderGroupName)
        block=stm.internal.blocks.SignalSourceBlock.getBlock(modelToRun);
        [simWatcher.cleanupIteration.SignalBuilder,...
        simWatcher.cleanupIteration.SigBuilderIndex]=...
        block.setActiveComponent(simInputs.SigBuilderGroupName);
    end

    if(~isempty(simInputs.TestIteration)&&~isempty(simInputs.TestIteration.SignalBuilderGroups))
        [overridesCache,originalSigBuilderParameters,tmpOut]=...
        iterationWrapper.applyIterationSigBuilderGroups(simInputs.TestIteration.SignalBuilderGroups);

        out.messages=[out.messages,tmpOut.messages];
        out.errorOrLog=[out.errorOrLog,tmpOut.errorOrLog];
        out.IterationSignalBuilderGroupsParameters=overridesCache;
        simWatcher.cleanupIteration.SignalBuilderGroups.orignalValues=originalSigBuilderParameters;
    end

end
