function h=propsrc_fp_blk(varargin)









    persistent RPTGEN_PROPSRC_FP_BLK

    if isempty(RPTGEN_PROPSRC_FP_BLK)
        RPTGEN_PROPSRC_FP_BLK=feval(['rptgen_fp.',mfilename]);

        RPTGEN_PROPSRC_FP_BLK.PropertyListeners=...
        makeModelChangeListener(rptgen_sl.appdata_sl,@changedModel);
    end

    h=RPTGEN_PROPSRC_FP_BLK;


    function changedModel(hProp,eventData)%#ok




        reset(rptgen_fp.propsrc_fp_blk);