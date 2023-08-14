
function t=pir_fixpt_t(varargin)



















pir_udd

    signed=varargin{1};
    if signed
        t=pir_sfixpt_t(varargin{2:end});
    else
        t=pir_ufixpt_t(varargin{2:end});
    end


