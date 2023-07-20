function op=hdleqop(op)





    op=strtrim(op);

    if hdlgetparameter('isvhdl')
        switch op
        case{'~=','!='}
            op='/=';
        case '=='
            op='=';
        otherwise
            op=op;
        end
    elseif hdlgetparameter('isverilog')
        switch op
        case{'~=','/='}
            op='!=';
        case '='
            op='==';
        otherwise
            op=op;
        end
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end


