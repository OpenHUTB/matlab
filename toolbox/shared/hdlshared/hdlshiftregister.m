function[hdlbody,hdlsignals]=hdlshiftregister(varargin)















    if hdlgetparameter('isvhdl')
        [hdlbody,hdlsignals]=vhdlshiftregister(varargin{:});
    elseif hdlgetparameter('isverilog')
        [hdlbody,hdlsignals]=verilogshiftregister(varargin{:});
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end
