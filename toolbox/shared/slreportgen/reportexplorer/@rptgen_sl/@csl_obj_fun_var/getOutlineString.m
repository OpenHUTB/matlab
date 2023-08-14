function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_obj_fun_var:unlicensedComponentLabel'));
        return;

    end


    if c.isFunctionTable
        typeStr=getString(message('RptgenSL:rsl_csl_obj_fun_var:functionLabel'));
        conjStr='/';
    else
        typeStr='';
        conjStr='';
    end

    if c.isVariableTable
        typeStr=[typeStr,conjStr,getString(message('RptgenSL:rsl_csl_obj_fun_var:variableLabel'))];
    end

    loopInfo=findContextBlocksDesc(rptgen_sl.appdata_sl,c);

    s=[typeStr,' ',getString(message('RptgenSL:rsl_csl_obj_fun_var:tableLabel')),...
    ' - ',...
    loopInfo];
