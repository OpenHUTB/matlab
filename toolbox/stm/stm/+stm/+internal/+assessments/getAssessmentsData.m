








function value = getAssessmentsData( testCaseID, objID, property )

R36
testCaseID( 1, 1 )double
objID( 1, 1 )double
property( 1, 1 )string{ mustBeMember( property, [ "enabled", "assessmentName" ] ) }
end 



assessmentID = stm.internal.getAssessmentsID( testCaseID );


assessmentInfoJSON = stm.internal.getAssessmentsInfo( assessmentID );


assessDataStruct = jsondecode( assessmentInfoJSON );

value = stm.internal.assessments.getAssessmentsDataHelper( assessDataStruct, objID, property );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmps4iqy4.p.
% Please follow local copyright laws when handling this file.

