function outlineString=getOutlineString(this)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        outlineString=getString(message('RptgenSL:rsl_csl_sys_snap:unlicensedLbl'));
        return
    end

    outlineString=this.getName;
    if(this.isPrintFrame&&~isempty(this.PrintFrameName))
        outlineString=[outlineString,' - ',this.PrintFrameName];
    end
