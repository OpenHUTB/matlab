function requirements = getAssessmentRequirements( testCaseID, objID )

arguments
    testCaseID( 1, 1 )double
    objID( 1, 1 )double
end



assessUUID = stm.internal.getAssessmentsUUID( testCaseID );


reqId = [ assessUUID, ':', num2str( objID ) ];


testfileLocation = stm.internal.getTestCaseProperty( testCaseID, 'Location' );

requirements = stm.internal.util.getReqs( testfileLocation, reqId );

end

