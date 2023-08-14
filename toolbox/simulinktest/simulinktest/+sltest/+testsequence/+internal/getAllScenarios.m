
function scenarios=getAllScenarios(testSequencePath)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        scenarios=T.getAllScenarios();
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end