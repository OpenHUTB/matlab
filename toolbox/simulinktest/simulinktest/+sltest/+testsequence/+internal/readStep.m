
function output_args=readStep(testSequencePath,step,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        output_args=T.readStep(step,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end
