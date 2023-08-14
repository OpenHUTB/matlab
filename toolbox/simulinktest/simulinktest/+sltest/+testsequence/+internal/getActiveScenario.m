function activeScenarioName=getActiveScenario(testSequencePath)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true,true);
        activeScenarioName=T.getActiveScenario();
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end