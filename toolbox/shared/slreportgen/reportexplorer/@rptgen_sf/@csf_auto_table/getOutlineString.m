function s=getOutlineString(c)








    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsf_csf_auto_table:unlicensedComponentLabel'));
        return;

    end

    s=getString(message('RptgenSL:rsf_csf_auto_table:sfAutoTableLabel'));
