function scenarioControlSource=getScenarioControlSource(testSequencePath)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        scenarioControlSource=T.getScenarioControlSource();
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end