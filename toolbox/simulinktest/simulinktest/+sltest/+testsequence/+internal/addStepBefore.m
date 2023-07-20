
function addStepBefore(testSequencePath,stepName,beforeStepName,varargin)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.addStepBefore(stepName,beforeStepName,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end