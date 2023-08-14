function s=getOutlineString(c)







    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_blk_toworkspace:unlicensedComponentLabel'));
        return;

    end

    loopInfo=findContextBlocksDesc(rptgen_sl.appdata_sl,c,getString(message('RptgenSL:rsl_csl_blk_toworkspace:toWorkspaceLabel')));

    s=[getString(message('RptgenSL:rsl_csl_blk_toworkspace:plotLabel')),' - ',loopInfo];