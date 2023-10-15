function removeAssessmentsData( testCaseID, objID )

arguments
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

