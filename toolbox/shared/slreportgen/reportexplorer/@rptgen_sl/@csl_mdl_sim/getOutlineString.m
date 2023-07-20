function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_mdl_sim:unlicensedComponentLabel'));
        return;

    end


    if c.UseMdlTimespan
        tSpan=getString(message('RptgenSL:rsl_csl_mdl_sim:useModelTimeLabel'));
    else
        tSpan=['[',c.StartTime,':',c.EndTime,']'];
    end

    s=[getString(message('RptgenSL:rsl_csl_mdl_sim:simulateModelLabel')),' - ',tSpan];