
function output=readSymbol(testSequencePath,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        output=T.readSymbol(varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end

