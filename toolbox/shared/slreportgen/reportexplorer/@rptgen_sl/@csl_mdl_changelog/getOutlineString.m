function s=getOutlineString(c)









    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_mdl_changelog:unlicensedComponentLabel'));
        return;

    end


    if c.isLimitRevisions
        revLimit=sprintf(getString(message('RptgenSL:rsl_csl_mdl_changelog:lastNRevisionsLabel')),c.NumRevisions);
    else
        revLimit=getString(message('RptgenSL:rsl_csl_mdl_changelog:allRevisionsLabel'));
    end

    s=[c.getName,' - ',revLimit];
