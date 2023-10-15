function outputStructArray = getAssessmentStructArray( testCaseID, objID, fieldName )

arguments
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

