function outlineString=getOutlineString(this)





    if~builtin('license','checkout','SIMULINK_Report_Gen')
        outlineString=getString(message('RptgenSL:rsl_csl_sys_list:unlicensedComponentLabel'));
        return;
    end

    if strcmp(this.StartSys,'fromloop')
        scopeString=getString(message('RptgenSL:rsl_csl_sys_list:fromCurrentSystemLabel'));
    else
        scopeString=getString(message('RptgenSL:rsl_csl_sys_list:entireModelLabel'));
    end

    outlineString=[this.getName,' - ',scopeString];


