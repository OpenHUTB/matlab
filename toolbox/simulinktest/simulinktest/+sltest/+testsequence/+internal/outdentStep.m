
function outdentStep(testSequencePath,stepName)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.outdentStep(stepName);
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end
