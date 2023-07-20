
function setProperty(testSequencePath,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.setProperty(varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end

