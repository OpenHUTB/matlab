
function editStep(testSequencePath,stepName,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.editStep(stepName,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end
