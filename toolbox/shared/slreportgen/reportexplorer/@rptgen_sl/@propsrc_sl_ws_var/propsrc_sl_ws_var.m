function this=propsrc_sl_ws_var(varargin)








    persistent RPTGEN_PROPSRC_SL_VAR

    if isempty(RPTGEN_PROPSRC_SL_VAR)
        RPTGEN_PROPSRC_SL_VAR=feval(['rptgen_sl.',mfilename]);
    end

    this=RPTGEN_PROPSRC_SL_VAR;
