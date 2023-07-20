
function editScenario(testSequencePath,currentScenarioName,varargin)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.editScenario(currentScenarioName,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end