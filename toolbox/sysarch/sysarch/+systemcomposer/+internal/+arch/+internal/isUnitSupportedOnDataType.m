function isSupported = isUnitSupportedOnDataType( dataTypeStr )

arguments
    dataTypeStr( 1, 1 )string
end

supportedTypes = [  ...
    "double", "single", "int8", "uint8", "int16", "uint16" ...
    , "int32", "uint32", "int64", "uint64" ];

isSupported = any( strcmp( dataTypeStr, supportedTypes ) );

end
