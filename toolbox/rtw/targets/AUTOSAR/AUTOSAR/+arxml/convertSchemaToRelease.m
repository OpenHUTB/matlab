
function release=convertSchemaToRelease(schemaVer)




    switch schemaVer
    case '00045'
        release='R18-03';
    case '00046'
        release='R18-10';
    case '00047'
        release='R19-03';
    case '00048'
        release='R19-11';
    case '00049'
        release='R20-11';
    otherwise

        release=schemaVer;
    end
end
