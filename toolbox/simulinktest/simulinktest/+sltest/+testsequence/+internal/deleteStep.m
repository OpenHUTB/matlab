
function deleteStep(testSequencePath,stepName)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.deleteStep(stepName);
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end

