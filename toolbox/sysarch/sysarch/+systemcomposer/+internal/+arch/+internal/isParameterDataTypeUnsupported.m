function TF = isParameterDataTypeUnsupported( type )

arguments
    type( 1, 1 )string
end

supportedTypes = [  ...
    "double", "single", "int8", "uint8", "int16", "uint16" ...
    , "int32", "uint32", "int64", "uint64", "boolean", "string" ];

TF = isempty( find( strcmp( type, supportedTypes ), 1 ) );

end

