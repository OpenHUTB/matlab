
function addTransition(testSequencePath,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.addTransition(varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end