function assessDataStruct = changeAssessmentsDataHelper( assessDataStruct, fieldName, objID, property, value )

arguments
    assessDataStruct
    fieldName( 1, 1 )string{ mustBeMember( fieldName, [ "AssessmentsInfo", "MappingInfo" ] ) }
    objID( 1, 1 )double
    property( 1, 1 )string{ mustBeMember( property, [ "enabled", "assessmentName" ] ) }
    value( 1, 1 )
end

for i = 1:length( assessDataStruct.( fieldName ) )
    if ( assessDataStruct.( fieldName ){ i }.id == objID )
        assessDataStruct.( fieldName ){ i }.( property ) = value;
        return ;
    end
end

end

