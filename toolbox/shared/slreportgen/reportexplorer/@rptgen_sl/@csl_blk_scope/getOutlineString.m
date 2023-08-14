function s=getOutlineString(c)







    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_blk_scope:unlicensedComponentLabel'));
        return;

    end

    if c.isForceOpen
        typeString='XY graph & scope';
    else
        typeString='XY graph & open scope';
    end

    loopInfo=findContextBlocksDesc(rptgen_sl.appdata_sl,c,typeString);

    s=[getString(message('RptgenSL:rsl_csl_blk_scope:scopeSnapshotLabel')),' - ',loopInfo];
