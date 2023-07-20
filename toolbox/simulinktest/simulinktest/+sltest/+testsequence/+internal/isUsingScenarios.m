
function res=isUsingScenarios(testSequencePath)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        res=T.isUsingScenarios();
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end