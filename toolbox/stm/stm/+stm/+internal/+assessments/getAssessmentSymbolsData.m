function value = getAssessmentSymbolsData( testCaseID, objID, property )

arguments
    testCaseID( 1, 1 )double
    objID( 1, 1 )double
    property( 1, 1 )string{ mustBeMember( property, [ "Name", "Scope", "Value" ] ) }
end

assessmentID = stm.internal.getAssessmentsID( testCaseID );
if assessmentID > 0
    assessmentJSON = stm.internal.getAssessmentsInfo( assessmentID );
    value = stm.internal.assessments.getAssessmentSymbolsDataHelper( assessmentJSON, objID, property );



    if isequal( property, "Scope" )
        value = sltest.testmanager.AssessmentSymbolScope( value );
    end
end

end

