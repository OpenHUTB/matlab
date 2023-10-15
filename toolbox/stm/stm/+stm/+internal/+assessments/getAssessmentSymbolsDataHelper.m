function value = getAssessmentSymbolsDataHelper( assessmentJSON, objID, property )

arguments
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

