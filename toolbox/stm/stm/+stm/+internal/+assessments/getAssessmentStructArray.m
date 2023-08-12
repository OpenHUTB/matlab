








function outputStructArray = getAssessmentStructArray( testCaseID, objID, fieldName )

R36
testCaseID( 1, 1 )double
objID( 1, 1 )double
fieldName( 1, 1 )string{ mustBeMember( fieldName, [ "AssessmentsInfo", "MappingInfo" ] ) }
end 




assessmentID = stm.internal.getAssessmentsID( testCaseID );
assessmentInfoJSON = stm.internal.getAssessmentsInfo( assessmentID );

if ~isempty( assessmentInfoJSON )
assessDataStruct = jsondecode( assessmentInfoJSON );
outputStructArray = stm.internal.assessments.getAssessmentStructArrayHelper( assessDataStruct, objID, fieldName );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpyYBfqT.p.
% Please follow local copyright laws when handling this file.

