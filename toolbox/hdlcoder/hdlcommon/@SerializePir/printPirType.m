function outStr=printPirType(slType)
    if isSLEnumType(slType)
        error(message('HDLShared:hdlshared:invaliddatatype',slType));
    end

    if strcmpi(slType(1:4),'sfix')
        [wlen,flen]=parseFixptType(slType);
        outStr=['pir_sfixpt_t(',num2str(wlen),',',num2str(flen),')'];
    elseif strcmpi(slType(1:4),'ufix')
        [wlen,flen]=parseFixptType(slType);
        outStr=['pir_ufixpt_t(',num2str(wlen),',',num2str(flen),')'];
    else
        switch slType
        case 'boolean'
            outStr='pir_boolean_t';
        case 'int16'
            outStr='pir_signed_t(16)';
        case 'int8'
            outStr='pir_signed_t(8)';
        case 'uint16'
            outStr='pir_unsigned_t(16)';
        case 'uint8'
            outStr='pir_unsigned_t(8)';
        case 'double'
            outStr='pir_double_t';
        case 'uint32'
            outStr='pir_unsigned_t(32)';
        case 'int32'
            outStr='pir_signed_t(32)';
        case 'single'
            outStr='pir_single_t';
        case 'uint64'
            outStr='pir_unsigned_t(64)';
        case 'int64'
            outStr='pir_signed_t(64)';
        otherwise
            error(message('HDLShared:hdlshared:invaliddatatype',slType));
        end
    end
end

function[wlen,flen]=parseFixptType(dt)
    try
        nt=numerictype(dt);
        wlen=nt.WordLength;


        flen=-nt.FractionLength;
    catch
        if dt(1)=='s'
            warning(message('HDLShared:hdlshared:unhandledsfix',dt));
        else
            warning(message('HDLShared:hdlshared:unhandledufix',dt));
        end
        wlen=32;
        flen=0;
    end
end
