









function value = getAssessmentSymbolsDataHelper( assessmentJSON, objID, property )

R36
assessmentJSON( 1, 1 )string
objID( 1, 1 )double
property( 1, 1 )string{ mustBeMember( property, [ "Name", "Scope", "Value" ] ) }
end 

value = [  ];
result = stm.internal.getAssessmentsDefinitionHelper( assessmentJSON );
symbolsArray = result.symbolsDefinition;
for i = 1:length( symbolsArray )
if isequal( symbolsArray{ i }.ID, objID )
value = symbolsArray{ i }.( property );
return ;
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpiYf0WV.p.
% Please follow local copyright laws when handling this file.

