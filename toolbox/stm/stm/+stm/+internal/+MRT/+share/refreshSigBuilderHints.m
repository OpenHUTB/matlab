


function out=refreshSigBuilderHints(model,harnessName)
    out.groupnames={};
    out.blockName='';
    out.description='';


    load_system(model);

    modelToUse=model;
    deactivateHarness=false;
    currHarness=[];
    oldHarness=[];
    wasHarnessOpen=false;

    if(~isempty(harnessName))
        [modelToUse,deactivateHarness,currHarness,oldHarness,out.description,wasHarnessOpen]=...
        stm.internal.util.resolveHarness(model,harnessName);
    end

    signalEditorBlock=stm.internal.blocks.SignalEditorBlock(modelToUse);
    if(~isempty(signalEditorBlock.handle))
        signalSourceBlock=signalEditorBlock;

        signalBuilderBlock=stm.internal.blocks.SignalBuilderBlock(modelToUse);
        if(~isempty(signalBuilderBlock.getHandle()))
            stm.internal.MRT.share.error('stm:general:TooManyInputSourceBlocks',modelToUse);
        end
    else
        signalBuilderBlock=stm.internal.blocks.SignalBuilderBlock(modelToUse);
        signalSourceBlock=signalBuilderBlock;
    end
    sigsH=signalSourceBlock.handle;
    if~isempty(sigsH)
        out.groupnames=signalSourceBlock.getComponentNames();
        out.blockName=sigsH;
        out.getSignalBlockType=signalSourceBlock.getSignalBlockType;
    end


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end
end
