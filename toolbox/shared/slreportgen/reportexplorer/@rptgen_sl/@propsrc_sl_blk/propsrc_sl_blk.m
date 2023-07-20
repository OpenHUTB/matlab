function h=propsrc_sl_blk(varargin)







    persistent RPTGEN_PROPSRC_SL_BLK

    if isempty(RPTGEN_PROPSRC_SL_BLK)
        RPTGEN_PROPSRC_SL_BLK=feval(['rptgen_sl.',mfilename]);
    end

    h=RPTGEN_PROPSRC_SL_BLK;