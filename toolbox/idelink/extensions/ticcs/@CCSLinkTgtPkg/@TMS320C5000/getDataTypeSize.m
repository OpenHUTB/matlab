function ret=getDataTypeSize(h,simulinkType)




    switch simulinkType
    case 'double'
        ret=4;
    case{'single','int32','uint32'}
        ret=4;
    case{'int16','uint16'}
        ret=2;
    case{'int8','uint8','boolean'}
        ret=2;
    otherwise
        error(message('ERRORHANDLER:utils:InvalidSimulinkDataType',simulinkType));
    end

