
function addStep(testSequencePath,stepName,varargin)
    try

        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.addStep(stepName,varargin{:});
        clear T;
    catch ME
        throwAsCaller(ME);
    end

end