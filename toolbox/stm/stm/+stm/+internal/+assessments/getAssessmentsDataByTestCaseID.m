





function assessmentsStructArr = getAssessmentsDataByTestCaseID( testCaseID )

R36
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpesiVFh.p.
% Please follow local copyright laws when handling this file.

