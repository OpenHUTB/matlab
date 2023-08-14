function s=getOutlineString(c)







    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_blk_bus:unlicensedComponentMsg'));
        return;

    end

    if c.isHierarchy
        lType=getString(message('RptgenSL:rsl_csl_blk_bus:fullTreeLabel'));
    else
        lType=getString(message('RptgenSL:rsl_csl_blk_bus:busAndChildrenLabel'));
    end

    s=[getString(message('RptgenSL:rsl_csl_blk_bus:busListLabel')),' - ',lType];
