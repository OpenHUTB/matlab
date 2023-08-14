function privmakehdl(varargin)



    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if length(varargin)<1
        error(message('hdlcoder:makehdl:hdldeprecation','makehdl','makehdl','makehdl'));
    elseif mod(length(varargin),2)~=1
        error(message('hdlcoder:makehdl:makehdl_invalid_pv_pairs'));
    end

    slhdlcoder.checkLicense;
    [hc,params]=hdlcoderargs(varargin{:});


    hc.WebBrowserHandles.remove(hc.WebBrowserHandles.keys());

    hc.makehdl(params);


    hdlcurrentdriver([]);
end
