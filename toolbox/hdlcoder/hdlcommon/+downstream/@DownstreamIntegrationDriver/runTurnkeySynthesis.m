function runTurnkeySynthesis( obj )


if obj.isTurnkeyWorkflow || obj.isXPCWorkflow
obj.run( 'CreateProject' );
obj.run( 'Synthesis' );
obj.run( { 'Map', 'PostMapTiming' } );
obj.run( { 'PAR', 'PostPARTiming' } );
obj.run( 'ProgrammingFile' );
obj.hTurnkey.runPostProgramFilePass;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2kHmih.p.
% Please follow local copyright laws when handling this file.

