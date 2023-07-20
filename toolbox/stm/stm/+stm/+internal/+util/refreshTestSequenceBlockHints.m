function[blockpaths,description]=refreshTestSequenceBlockHints(...
    modelName,harnessName)





    blockpaths={};
    description='';

    load_system(modelName);

    modelToUse=modelName;
    deactivateHarness=false;
    currHarness=[];
    oldHarness=[];
    wasHarnessOpen=false;

    if(~isempty(harnessName))
        [modelToUse,deactivateHarness,currHarness,oldHarness,description,wasHarnessOpen]=...
        stm.internal.util.resolveHarness(modelName,harnessName);
    end



    TSblocks=find_system(modelToUse,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',2,'SFBlockType','Test Sequence');


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end

    if~isempty(TSblocks)
        blockpaths=TSblocks;
    end
end
