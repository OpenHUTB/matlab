function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsf_csf_obj_snap:unlicensedComponentLabel'));
        return;
    end

    s=c.getName;
