function outputStructArray = getAssessmentStructArrayHelper( assessDataStruct, objID, fieldName )

arguments
    assessDataStruct
    objID( 1, 1 )double
    fieldName( 1, 1 )string{ mustBeMember( fieldName, [ "AssessmentsInfo", "MappingInfo" ] ) }
end

assessmentsInfo = assessDataStruct.( fieldName );
assessmentGraph = stm.internal.assessments.createAssessmentGraph( assessmentsInfo );
structIDs = dfsearch( assessmentGraph, string( objID ) );
outputStructArray = [  ];
for i = 1:length( assessmentsInfo )
    if ismember( string( assessmentsInfo{ i }.id ), structIDs )
        outputStructArray = [ outputStructArray;assessmentsInfo( i ) ];
    end
end

end

