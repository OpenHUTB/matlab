function isSupported = isUnitSupportedOnDataType( dataTypeStr )




R36
dataTypeStr( 1, 1 )string
end 

supportedTypes = [  ...
"double", "single", "int8", "uint8", "int16", "uint16" ...
, "int32", "uint32", "int64", "uint64" ];

isSupported = any( strcmp( dataTypeStr, supportedTypes ) );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp_lFntL.p.
% Please follow local copyright laws when handling this file.

