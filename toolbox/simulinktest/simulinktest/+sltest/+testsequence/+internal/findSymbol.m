
function output_arg=findSymbol(testSequencePath,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        output_arg=T.findSymbol(varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end

