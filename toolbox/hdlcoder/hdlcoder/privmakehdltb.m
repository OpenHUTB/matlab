function privmakehdltb(varargin)








    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    slhdlcoder.checkLicense;

    if length(varargin)<1
        error(message('hdlcoder:makehdl:hdldeprecation','makehdltb','makehdltb','makehdltb'));
    elseif mod(length(varargin),2)~=1
        error(message('hdlcoder:makehdl:makehdltb_invalid_pv_pairs'));
    end

    [hc,params]=hdlcoderargs(varargin{:});


    hc.makehdltb(params);
end
