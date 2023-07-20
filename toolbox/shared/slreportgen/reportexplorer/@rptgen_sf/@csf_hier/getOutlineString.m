function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsf_csf_hier:unlicensedComponentLabel'));
        return;

    end

    s=[c.getName,' - ',c.TreeType];




