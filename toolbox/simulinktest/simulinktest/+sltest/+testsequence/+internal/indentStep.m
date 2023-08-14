
function indentStep(testSequencePath,stepName)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.indentStep(stepName);
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end
