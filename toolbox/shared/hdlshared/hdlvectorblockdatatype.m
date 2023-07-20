function vtype=hdlblockdatatype(varargin)





    if hdlgetparameter('isvhdl')
        vtype=vhdlvectorblockdatatype(varargin{:});
    elseif hdlgetparameter('isverilog')
        vtype=verilogvectorblockdatatype(varargin{:});
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end




