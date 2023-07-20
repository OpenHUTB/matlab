
function deleteSymbol(testSequencePath,symbolName)
    try
        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.deleteSymbol(symbolName);
        clear T;
    catch ME
        throwAsCaller(ME);
    end

