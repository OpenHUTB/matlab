function final_result=hdlsaturate(varargin)












    if hdlgetparameter('isvhdl')
        final_result=vhdlsaturate(varargin{:});
    elseif hdlgetparameter('isverilog')
        final_result=verilogsaturate(varargin{:});
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end



