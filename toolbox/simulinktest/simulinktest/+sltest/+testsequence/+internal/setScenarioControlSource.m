function setScenarioControlSource( testSequencePath, source )
R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpgqjWbP.p.
% Please follow local copyright laws when handling this file.

