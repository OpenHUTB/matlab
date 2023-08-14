function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_blk_sort_list:unlicensedComponentLabel'));
        return;

    end


    switch c.FollowNonVirtual
    case 'on'
        fType=getString(message('RptgenSL:rsl_csl_blk_sort_list:followConcreteLabel'));
    case 'off'
        fType=getString(message('RptgenSL:rsl_csl_blk_sort_list:currentSystemLabel'));
    case 'auto'
        fType=getString(message('RptgenSL:rsl_csl_blk_sort_list:followModelConcreteLabel'));
    end

    s=[getString(message('RptgenSL:rsl_csl_blk_sort_list:sortedBlockListLabel')),' - ',fType];