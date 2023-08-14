
function editSymbol(testSequencePath,symbol,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.editSymbol(symbol,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end

