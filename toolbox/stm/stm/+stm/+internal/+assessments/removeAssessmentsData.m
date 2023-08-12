






function removeAssessmentsData( testCaseID, objID )

R36
testCaseID( 1, 1 )double
objID( 1, 1 )double
end 




assessmentID = stm.internal.getAssessmentsID( testCaseID );
assessmentInfoJSON = stm.internal.getAssessmentsInfo( assessmentID );
assessDataStruct = jsondecode( assessmentInfoJSON );

if ~isempty( assessDataStruct )
assessDataStruct = stm.internal.assessments.removeAssessmentsDataHelper( assessDataStruct, objID );
if isempty( assessDataStruct.AssessmentsInfo ) &&  ...
isempty( assessDataStruct.MappingInfo ) &&  ...
isempty( assessDataStruct.MappingInfo2 )
updatedAssessJSON = char.empty;
else 
updatedAssessJSON = jsonencode( assessDataStruct );
end 
stm.internal.setAssessmentsInfo( assessmentID, updatedAssessJSON );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpU_P9aZ.p.
% Please follow local copyright laws when handling this file.

