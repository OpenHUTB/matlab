function scenarionames=refreshTestSequenceScenarioHints(...
    modelName,harnessName,blockPath)





    scenarionames={};

    load_system(modelName);

    if isempty(blockPath)
        error(message('stm:general:NoTestSequenceBlockSpecified'));
    end

    modelToUse=modelName;
    deactivateHarness=false;
    currHarness=[];
    oldHarness=[];
    wasHarnessOpen=false;

    if(~isempty(harnessName))
        [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=...
        stm.internal.util.resolveHarness(modelName,harnessName);
    end

    find_system(blockPath,'SearchDepth',1);

    if~sltest.testsequence.isUsingScenarios(blockPath)
        error(message('stm:general:TestSequenceNoScenario',blockPath));
    end

    scenarionames=sltest.testsequence.getAllScenarios(blockPath);


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end
end