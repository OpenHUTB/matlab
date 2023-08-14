function activateScenario(testSequencePath,scenarioName)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,false,true);
        T.activateScenario(scenarioName);
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end