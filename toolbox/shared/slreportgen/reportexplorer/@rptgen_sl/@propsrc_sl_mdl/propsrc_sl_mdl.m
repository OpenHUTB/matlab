function h=propsrc_sl_mdl(varargin)







    persistent RPTGEN_PROPSRC_SL_MDL

    if isempty(RPTGEN_PROPSRC_SL_MDL)
        RPTGEN_PROPSRC_SL_MDL=feval(['rptgen_sl.',mfilename]);
    end

    h=RPTGEN_PROPSRC_SL_MDL;