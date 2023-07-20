
function cleanupTestSequenceScenario(simWatcher)

    cleanupStruct=simWatcher.cleanupIteration;

    if(isfield(cleanupStruct,'prevScenarioParamInitVal')&&isfield(cleanupStruct,'testSeqPath')...
        &&~isempty(cleanupStruct.testSeqPath))
        tsBlockPath=cleanupStruct.testSeqPath;
        rt=sfroot();
        chart=rt.find('-isa','Stateflow.ReactiveTestingTableChart','Path',tsBlockPath);
        sttman=Stateflow.STT.StateEventTableMan(chart.Id);
        viewManager=sttman.viewManager;
        viewManager.scenarioParamVal(cleanupStruct.prevScenarioParamInitVal);
    end

end