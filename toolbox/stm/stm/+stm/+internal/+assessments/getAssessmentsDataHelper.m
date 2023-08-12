








function value = getAssessmentsDataHelper( assessDataStruct, objID, property )

R36
assessDataStruct
objID( 1, 1 )double
property( 1, 1 )string{ mustBeMember( property, [ "enabled", "assessmentName" ] ) }
end 

fieldName = "AssessmentsInfo";
value = [  ];
for i = 1:length( assessDataStruct.( fieldName ) )
if ( assessDataStruct.( fieldName ){ i }.id == objID )
value = assessDataStruct.( fieldName ){ i }.( property );
return ;
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpbkDUst.p.
% Please follow local copyright laws when handling this file.

