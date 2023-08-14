
function deleteTransition(testSequencePath,stepName,index)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.deleteTransition(stepName,index);
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end

