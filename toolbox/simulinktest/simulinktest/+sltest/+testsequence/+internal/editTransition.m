
function editTransition(testSequencePath,stepName,index,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.editTransition(stepName,index,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end

