function matlabDataType = toMatlabDataType( tdmsDataType )

arguments
    tdmsDataType( 1, : )string
end

matlabDataType = strings( size( tdmsDataType ) );

for i = 1:numel( tdmsDataType )
    switch tdmsDataType( i )
        case "Int8"
            matlabDataType( i ) = "int8";
        case "UInt8"
            matlabDataType( i ) = "uint8";
        case "Int16"
            matlabDataType( i ) = "int16";
        case "UInt16"
            matlabDataType( i ) = "uint16";
        case "Int32"
            matlabDataType( i ) = "int32";
        case "UInt32"
            matlabDataType( i ) = "uint32";
        case "Int64"
            matlabDataType( i ) = "int64";
        case "UInt64"
            matlabDataType( i ) = "uint64";
        case "Float"
            matlabDataType( i ) = "single";
        case "Double"
            matlabDataType( i ) = "double";
        case "String"
            matlabDataType( i ) = "string";
        case "Boolean"
            matlabDataType( i ) = "logical";
        case "Timestamp"
            matlabDataType( i ) = "datetime";
        case "<UnknownType> : 0"
            matlabDataType( i ) = "double";
        otherwise
            matlabDataType( i ) = string( missing );
    end
end
end
