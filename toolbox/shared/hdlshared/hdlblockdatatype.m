function vtype=hdlblockdatatype(dt)





    if hdlgetparameter('isvhdl')
        vtype=vhdlblockdatatype(dt);
    elseif hdlgetparameter('isverilog')
        vtype=verilogblockdatatype(dt);
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end




