function TF = isParameterDataTypeUnsupported( type )




R36
type( 1, 1 )string
end 

supportedTypes = [  ...
"double", "single", "int8", "uint8", "int16", "uint16" ...
, "int32", "uint32", "int64", "uint64", "boolean", "string" ];

TF = isempty( find( strcmp( type, supportedTypes ), 1 ) );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp197TeE.p.
% Please follow local copyright laws when handling this file.

