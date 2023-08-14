
function output_arg=findStep(testSequencePath,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        output_arg=T.findStep(varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end
