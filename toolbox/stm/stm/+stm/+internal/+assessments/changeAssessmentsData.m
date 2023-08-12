









function changeAssessmentsData( testCaseID, objID, property, value )

R36
testCaseID( 1, 1 )double
objID( 1, 1 )double
property( 1, 1 )string{ mustBeMember( property, [ "enabled", "assessmentName" ] ) }
value( 1, 1 )
end 



assessmentID = stm.internal.getAssessmentsID( testCaseID );
assessmentInfoJSON = stm.internal.getAssessmentsInfo( assessmentID );
assessDataStruct = jsondecode( assessmentInfoJSON );

if ~isempty( assessDataStruct )
fieldName = "AssessmentsInfo";
assessDataStruct = stm.internal.assessments.changeAssessmentsDataHelper( assessDataStruct, fieldName, objID, property, value );
updatedAssessJSON = jsonencode( assessDataStruct );
stm.internal.setAssessmentsInfo( assessmentID, updatedAssessJSON );
else 

end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpNoUo4W.p.
% Please follow local copyright laws when handling this file.

