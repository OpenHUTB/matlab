
function output=getProperty(testSequencePath,varargin)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath,true);
        output=T.getProperty(varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end

