function result=hdlconstantvalue(varargin)








    if hdlgetparameter('isvhdl')
        result=vhdlconstantvalue(varargin{:});
    elseif hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog')
        result=verilogconstantvalue(varargin{:});
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end




