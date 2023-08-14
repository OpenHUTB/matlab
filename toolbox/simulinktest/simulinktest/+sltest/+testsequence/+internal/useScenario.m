
function useScenario(testSequencePath,scenarioName)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.useScenario(scenarioName);
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end