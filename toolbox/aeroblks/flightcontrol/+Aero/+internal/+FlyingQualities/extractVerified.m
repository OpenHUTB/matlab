function fqStruct = extractVerified( fqStruct, tf )

arguments
fqStruct
tf( 1, 1 )logical = true
end 

fqStruct = fqStruct( [ fqStruct.Verified ] == tf );
end 


