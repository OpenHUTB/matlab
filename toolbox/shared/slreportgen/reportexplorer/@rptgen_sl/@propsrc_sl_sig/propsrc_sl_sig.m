function h=propsrc_sl_sig(varargin)







    persistent RPTGEN_PROPSRC_SL_SIG

    if isempty(RPTGEN_PROPSRC_SL_SIG)
        RPTGEN_PROPSRC_SL_SIG=feval(['rptgen_sl.',mfilename]);
    end

    h=RPTGEN_PROPSRC_SL_SIG;