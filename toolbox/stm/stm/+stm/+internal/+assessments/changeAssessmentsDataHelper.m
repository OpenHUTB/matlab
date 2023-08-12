










function assessDataStruct = changeAssessmentsDataHelper( assessDataStruct, fieldName, objID, property, value )

R36
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpf15a6U.p.
% Please follow local copyright laws when handling this file.

