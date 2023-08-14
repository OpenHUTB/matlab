
function deleteScenario(testSequencePath,scenarioName)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.deleteScenario(scenarioName);
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end