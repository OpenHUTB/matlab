function out=refreshConfigSetHints(model,harnessName)





    if isempty(model)
        stm.internal.MRT.share.error(('stm:general:NoModelSelected'));
    end


    load_system(model);
    deactivateHarness=false;
    currHarness=[];
    oldHarness=[];
    modelToUse=model;
    wasHarnessOpen=false;

    if(~isempty(harnessName))
        [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(model,harnessName);
    end

    try

        out=getConfigSets(modelToUse);
    catch
        stm.internal.MRT.share.error(('stm:general:InvalidModelNameInNewTestFileFromModelDialog'));
    end


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end
end
