function context=loop_getContextString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        context='';
        return;
    end

    switch lower(getContextType(rptgen_sf.appdata_sf,c,false))
    case 'model'
        context=getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:reportedSystemsLabel'));
    case 'system';
        context=getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:currentSystemLabel'));
    case 'signal'
        context=getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:currentSignalParentLabel'));
    case 'block'
        context=getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:currentBlockSystemLabel'));
    case 'annotation'
        context=getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:currentAnnotationParentLabel'));
    case 'configset'
        context=getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:noSystemsLabel'));
    otherwise
        context=getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:allSystemsLabel'));
    end


