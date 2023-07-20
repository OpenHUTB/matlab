
function output_args=readTransition(testSequencePath,step,index,varargin)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        output_args=T.readTransition(step,index,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end