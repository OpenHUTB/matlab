






function requirements = getAssessmentRequirements( testCaseID, objID )

R36
testCaseID( 1, 1 )double
objID( 1, 1 )double
end 



assessUUID = stm.internal.getAssessmentsUUID( testCaseID );


reqId = [ assessUUID, ':', num2str( objID ) ];


testfileLocation = stm.internal.getTestCaseProperty( testCaseID, 'Location' );

requirements = stm.internal.util.getReqs( testfileLocation, reqId );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp4NKfcx.p.
% Please follow local copyright laws when handling this file.

