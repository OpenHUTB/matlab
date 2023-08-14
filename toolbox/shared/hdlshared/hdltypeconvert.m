function final_result=hdltypeconvert(varargin)














    if hdlgetparameter('isvhdl')
        final_result=vhdltypeconvert(varargin{:});
    elseif hdlgetparameter('isverilog')
        final_result=verilogtypeconvert(varargin{:});
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end



