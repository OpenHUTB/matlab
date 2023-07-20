function h=propsrc_sl_sys(varargin)







    persistent RPTGEN_PROPSRC_SL_SYS

    if isempty(RPTGEN_PROPSRC_SL_SYS)
        RPTGEN_PROPSRC_SL_SYS=feval(['rptgen_sl.',mfilename]);
    end

    h=RPTGEN_PROPSRC_SL_SYS;