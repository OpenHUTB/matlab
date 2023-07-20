function s=getOutlineString(this)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rstm_cstm_testseq:unlicensedComponentLabel'));
        return;
    end

    s=getName(this);