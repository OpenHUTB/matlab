function setScenarioControlSource( testSequencePath, source )
arguments
    testSequencePath
    source( 1, 1 )sltest.testsequence.ScenarioControlSource
end

try
    T = sltest.testsequence.internal.TestSequenceManager( testSequencePath );
    T.setScenarioControlSource( source );
    clear T;
catch ME
    throwAsCaller( ME );
end
end

