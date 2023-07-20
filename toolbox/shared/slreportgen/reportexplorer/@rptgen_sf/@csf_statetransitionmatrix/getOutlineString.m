function s=getOutlineString(this)









    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsf_csf_statetransitionmatrix:unlicensedComponentLabel'));
        return;

    end

    s=getName(this);





