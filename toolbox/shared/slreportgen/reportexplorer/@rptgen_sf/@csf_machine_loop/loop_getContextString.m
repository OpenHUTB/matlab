function cs=loop_getContextString(c)






    sfContext=getContextType(rptgen_sf.appdata_sf,c,logical(0));

    if strcmpi(sfContext,'None')|isempty(sfContext)
        slContext=getContextType(rptgen_sl.appdata_sl,c,logical(0));
        if isempty(slContext)|strcmpi(slContext,'None')
            cs=getString(message('RptgenSL:rsf_csf_machine_loop:allMachinesLabel'));
        else
            cs=getString(message('RptgenSL:rsf_csf_machine_loop:currentModelsMachineLabel'));
        end
    else
        cs=getString(message('RptgenSL:rsf_csf_machine_loop:currentMachineLabel'));
    end
