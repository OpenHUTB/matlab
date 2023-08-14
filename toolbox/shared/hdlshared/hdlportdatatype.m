function vtype=hdlportdatatype(dt)





    if hdlgetparameter('isvhdl')
        vtype=vhdlportdatatype(dt);
    elseif hdlgetparameter('isverilog')
        vtype=verilogportdatatype(dt);
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end





