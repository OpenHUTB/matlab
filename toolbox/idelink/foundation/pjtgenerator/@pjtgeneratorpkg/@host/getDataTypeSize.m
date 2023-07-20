function ret=getDataTypeSize(~,simulinkType)





    switch simulinkType
    case 'double'
        ret=8;
    case{'single','int32','uint32'}
        ret=4;
    case{'int16','uint16'}
        ret=2;
    case{'int8','uint8','boolean'}
        ret=1;
    otherwise
        DAStudio.error('ERRORHANDLER:pjtgenerator:InvalidSimulinkType',simulinkType);
    end
