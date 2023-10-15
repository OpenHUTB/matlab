function paddedData = createPadding( type, size )

arguments
    type( 1, 1 )string
    size( 1, 2 )uint64
end
switch type
    case { 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64' }
        paddedData = zeros( size, type );
    case { 'double', 'single' }
        paddedData = NaN( size, type );
    case 'char'
        paddedData = repmat( { '' }, size );
    case 'string'
        paddedData = strings( size );
    case 'datetime'
        paddedData = NaT( size, "TimeZone", "local" );
    case 'duration'
        paddedData = seconds( NaN( size ) );
    case 'categorical'
        paddedData = categorical( repmat( { '' }, size ) );
    case 'logical'
        paddedData = false( size );
    otherwise
        assert( false, "Invalid type in padData" );
end
end
