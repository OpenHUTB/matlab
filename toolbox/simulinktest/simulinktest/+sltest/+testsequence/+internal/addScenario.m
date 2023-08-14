
function addScenario(testSequencePath,newScenarioName)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.addScenario(newScenarioName);
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end