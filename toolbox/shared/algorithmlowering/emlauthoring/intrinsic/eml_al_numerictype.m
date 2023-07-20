function nt=eml_al_numerictype(var)




%#codegen
    coder.allowpcode('plain');

    if isfloat(var)
        eml_assert(0);
    elseif isinteger(var)
        switch class(var)
        case 'int8'
            nt=numerictype(1,8,0);
        case 'int16'
            nt=numerictype(1,16,0);
        case 'int32'
            nt=numerictype(1,32,0);
        case 'int64'
            nt=numerictype(1,64,0);
        case 'uint8'
            nt=numerictype(0,8,0);
        case 'uint16'
            nt=numerictype(0,16,0);
        case 'uint32'
            nt=numerictype(0,32,0);
        case 'uint64'
            nt=numerictype(0,64,0);
        otherwise
            eml_assert(0);
        end
    else
        nt=numerictype(var);
    end
end
