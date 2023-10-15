function value = getAssessmentsData( testCaseID, objID, property )

arguments
    testCaseID( 1, 1 )double
    objID( 1, 1 )double
    property( 1, 1 )string{ mustBeMember( property, [ "enabled", "assessmentName" ] ) }
end



assessmentID = stm.internal.getAssessmentsID( testCaseID );


assessmentInfoJSON = stm.internal.getAssessmentsInfo( assessmentID );


assessDataStruct = jsondecode( assessmentInfoJSON );

value = stm.internal.assessments.getAssessmentsDataHelper( assessDataStruct, objID, property );

end


