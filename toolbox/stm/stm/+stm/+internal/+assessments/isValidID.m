function isValid = isValidID( testCaseID, objID, fieldName )

arguments
    testCaseID( 1, 1 )double
    objID( 1, 1 )double
    fieldName( 1, 1 )string{ mustBeMember( fieldName, [ "AssessmentsInfo", "MappingInfo" ] ) }
end

isValid = false;
assessmentID = stm.internal.getAssessmentsID( testCaseID );


if assessmentID < 0
    return ;
end

assessmentInfoJSON = stm.internal.getAssessmentsInfo( assessmentID );
if ~isempty( assessmentInfoJSON )
    assessDataStruct = jsondecode( assessmentInfoJSON );
    assessData = assessDataStruct.( fieldName );

    for i = 1:length( assessData )
        if isequal( assessData{ i }.id, objID )
            isValid = true;
            return ;
        end
    end
end

end

