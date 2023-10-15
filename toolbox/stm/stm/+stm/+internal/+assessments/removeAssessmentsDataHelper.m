function assessDataStruct = removeAssessmentsDataHelper( assessDataStruct, objID )

arguments
    assessDataStruct
    objID( 1, 1 )double
end

assessmentGraph = stm.internal.assessments.createAssessmentGraph( assessDataStruct.AssessmentsInfo );
structIDs = dfsearch( assessmentGraph, string( objID ) );
for i = 1:length( assessDataStruct.AssessmentsInfo )
    if ismember( string( assessDataStruct.AssessmentsInfo{ i }.id ), structIDs )
        assessDataStruct.AssessmentsInfo{ i } = [  ];
    end
end

assessDataStruct.AssessmentsInfo = assessDataStruct.AssessmentsInfo( ~cellfun( 'isempty', assessDataStruct.AssessmentsInfo ) );

end
