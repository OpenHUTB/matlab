






function info = getAssessmentInfoHelper( testCaseID, objID )

R36
testCaseID( 1, 1 )double
objID( 1, 1 )double
end 



assessmentID = stm.internal.getAssessmentsID( testCaseID );


assessmentInfoJSON = stm.internal.getAssessmentsInfo( assessmentID );

result = stm.internal.getAssessmentsDefinitionHelper( assessmentInfoJSON );
assessInfoArray = result.assessmentsDefinition;
for i = 1:length( assessInfoArray )
if isequal( assessInfoArray( i ).id, objID )
info = assessInfoArray( i ).textLabel;
return ;
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpIWcWqZ.p.
% Please follow local copyright laws when handling this file.

