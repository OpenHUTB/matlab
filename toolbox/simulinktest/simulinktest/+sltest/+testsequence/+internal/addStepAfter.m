
function addStepAfter(testSequencePath,stepName,afterStepName,varargin)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.addStepAfter(stepName,afterStepName,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end
