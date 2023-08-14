function str=hdllegalnamersvd(strin)





    if hdlgetparameter('isvhdl')
        str=vhdllegalnamersvd(strin);
    elseif hdlgetparameter('isverilog')
        str=veriloglegalnamersvd(strin);
    elseif hdlgetparameter('issystemverilog')
        str=veriloglegalnamersvd(strin);
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end




