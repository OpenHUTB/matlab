function str=hdllegalname(strin)


    if hdlispirbased
        if(isempty(strin))
            strin='';
        end



        str=hdlcoder.pirctx.legalizeName(strin,'');
    else
        if hdlgetparameter('isvhdl')
            str=vhdllegalname(strin);
        elseif hdlgetparameter('isverilog')
            str=veriloglegalname(strin);
        else
            error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
        end
    end
end


