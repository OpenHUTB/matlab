

function setupTestSequenceScenario(runCfg,simInStruct,simWatcher)
    if isempty(simInStruct.TestSequenceScenario)&&~isempty(simInStruct.TestIteration)&&...
        ~isempty(simInStruct.TestIteration.TestParameter)&&~isempty(simInStruct.TestIteration.TestParameter.TestSequenceScenario)
        simInStruct.TestSequenceScenario=simInStruct.TestIteration.TestParameter.TestSequenceScenario;
    end
    if~isempty(simInStruct.TestSequenceBlock)&&~isempty(simInStruct.TestSequenceScenario)
        tsBlockPath=simInStruct.TestSequenceBlock;
        rt=sfroot();
        chart=rt.find('-isa','Stateflow.ReactiveTestingTableChart','Path',tsBlockPath);
        sttman=Stateflow.STT.StateEventTableMan(chart.Id);
        viewManager=sttman.viewManager;
        tsScenario=simInStruct.TestSequenceScenario;
        if~isempty(simInStruct.TestIteration.TestParameter.TestSequenceScenario)
            tsScenario=simInStruct.TestIteration.TestParameter.TestSequenceScenario;
        end
        [~,activeIndex]=ismember(tsScenario,sltest.testsequence.internal.getAllScenarios(tsBlockPath));

        activeIndex=activeIndex-1;
        originalValue=viewManager.scenarioParamVal();
        simWatcher.cleanupIteration.prevScenarioParamInitVal=originalValue;
        simWatcher.cleanupIteration.testSeqPath=tsBlockPath;
        viewManager.jsActiveScenario(activeIndex);

    end
end