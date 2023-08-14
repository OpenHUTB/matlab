function[hdlbody,hdlsignals]=hdlringcounter(varargin)





















    if hdlgetparameter('isvhdl')
        [hdlbody,hdlsignals]=vhdlringcounter(varargin{:});
    elseif hdlgetparameter('isverilog')
        [hdlbody,hdlsignals]=verilogringcounter(varargin{:});
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end



