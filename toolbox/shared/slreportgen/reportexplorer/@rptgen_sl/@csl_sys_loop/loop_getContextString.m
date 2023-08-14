function context=loop_getContextString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        context='';
        return;

    end

    if strcmp(c.LoopType,'list')
        context=getString(message('RptgenSL:rsl_csl_sys_loop:customSystemsListLabel'));
    else
        switch lower(getContextType(rptgen_sl.appdata_sl,c,false))
        case 'model'
            context=getString(message('RptgenSL:rsl_csl_sys_loop:reportedSystemsLabel'));
        case 'system';
            context=getString(message('RptgenSL:rsl_csl_sys_loop:currentSystemLabel'));
        case 'signal'
            context=getString(message('RptgenSL:rsl_csl_sys_loop:currentSignalParentLabel'));
        case 'block'
            context=getString(message('RptgenSL:rsl_csl_sys_loop:currentBlockSystemLabel'));
        case 'annotation'
            context=getString(message('RptgenSL:rsl_csl_sys_loop:currentAnnotationParentLabel'));
        case 'configset'
            context=getString(message('RptgenSL:rsl_csl_sys_loop:noSystemsLabel'));
        otherwise
            context=getString(message('RptgenSL:rsl_csl_sys_loop:allSystemsLabel'));
        end
    end
