function[schemaVerNum,schemaVerString]=convertReleaseToSchema(releaseVer)



    switch releaseVer
    case 'R18-03'
        schemaVerString='00045';
    case 'R18-10'
        schemaVerString='00046';
    case 'R19-03'
        schemaVerString='00047';
    case 'R19-11'
        schemaVerString='00048';
    case 'R20-11'
        schemaVerString='00049';
    case 'R21-11'
        schemaVerString='00050';
    otherwise
        assert(false,'Release version not supported.');
    end
    schemaVerNum=str2double(schemaVerString);
end
