function s=getOutlineString(this)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_auto_table:unlicensedComponentLabel'));
        return;

    end

    oType=this.ObjectType;
    if strcmp(oType,'auto')
        oType=getContextType(rptgen_sl.appdata_sl,this,true);
    end

    s=sprintf(getString(message('RptgenSL:rsl_csl_auto_table:autoTableLabel')),rptgen.capitalizeFirst(oType));
