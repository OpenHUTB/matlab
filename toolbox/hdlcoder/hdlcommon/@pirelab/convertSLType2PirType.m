function pirtype=convertSLType2PirType(dt)








    if strncmpi(dt,'sfix',4)
        [wlen,flen]=parseFixptType(dt);
        pirtype=pir_sfixpt_t(wlen,flen);
    elseif strncmpi(dt,'ufix',4)
        [wlen,flen]=parseFixptType(dt);
        pirtype=pir_ufixpt_t(wlen,flen);
    else
        switch dt
        case 'boolean'
            pirtype=pir_boolean_t;
        case 'int16'
            pirtype=pir_signed_t(16);
        case 'int8'
            pirtype=pir_signed_t(8);
        case 'uint16'
            pirtype=pir_unsigned_t(16);
        case 'uint8'
            pirtype=pir_unsigned_t(8);
        case 'double'
            pirtype=pir_double_t;
        case 'uint32'
            pirtype=pir_unsigned_t(32);
        case 'int32'
            pirtype=pir_signed_t(32);
        case 'single'
            pirtype=pir_single_t;
        case 'half'
            pirtype=pir_half_t;
        case 'uint64'
            pirtype=pir_ufixpt_t(64,0);
        case 'int64'
            pirtype=pir_sfixpt_t(64,0);
        case 'action'
            pirtype=pir_boolean_t;
        otherwise
            if isSLEnumType(dt)
                pirtype=createEnumType(dt);
            elseif strncmp(dt,'str',3)&&hdlgetparameter('stringtypesupport')
                pirtype=pir_char_t;
            else

                illegalType(dt);
            end
        end
    end
end



function illegalType(dt)
    error(message('HDLShared:hdlshared:invaliddatatype',dt));
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


function pirtype=createEnumType(dtstr)
    if strncmpi('Enum:',dtstr,5)
        if dtstr(6)==' '
            dt=dtstr(7:end);
        else
            dt=dtstr(6:end);
        end
    else
        dt=dtstr;
    end
    [enumValues,enumStrings]=enumeration(dt);


    eType=eval(['?',dt]);
    eMethods=eType.MethodList;
    if numel(eMethods(arrayfun(@(x)strcmp(x.Name,'getDefaultValue'),...
        eMethods)))>0
        defaultOrdinal=find(enumValues==eval([dt,'.getDefaultValue']))-1;
    else
        defaultOrdinal=0;
    end



    pirtype=pir_enum_t(dt,enumStrings,int32(enumValues.double),defaultOrdinal);
end


