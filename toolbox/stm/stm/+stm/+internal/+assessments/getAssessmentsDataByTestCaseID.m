function assessmentsStructArr = getAssessmentsDataByTestCaseID( testCaseID )

arguments
    testCaseID( 1, 1 )double
end

testCaseObj = sltest.testmanager.TestCase( [  ], testCaseID );
assessments = testCaseObj.getAssessments;
assessmentsStructArr = struct(  );

if ~isempty( assessments )
    assessmentsStructArr = struct( 'Name', { assessments.Name },  ...
        'Enabled', { assessments.Enabled },  ...
        'Info', { assessments.Info } );

    for idx = 1:length( assessments )
        assessmentsStructArr( idx ).Info = char( assessments( idx ).Info );
    end
end

end
