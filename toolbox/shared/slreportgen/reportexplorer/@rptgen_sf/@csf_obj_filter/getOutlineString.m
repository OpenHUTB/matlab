function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsf_csf_obj_filter:unlicensedComponentLabel'));
        return;

    end


    s=sprintf(getString(message('RptgenSL:rsf_csf_obj_filter:filterLabel')),rptgen.capitalizeFirst(c.ObjectType));
