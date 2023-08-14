function this=propsrc_sl_datadict(varargin)








    persistent RPTGEN_PROPSRC_SL_DATADICT

    if isempty(RPTGEN_PROPSRC_SL_DATADICT)
        RPTGEN_PROPSRC_SL_DATADICT=feval(['rptgen_sl.',mfilename]);
    end

    this=RPTGEN_PROPSRC_SL_DATADICT;
