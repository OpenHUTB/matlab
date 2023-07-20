function context=loop_getContextString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        context='';
        return;

    end

    switch lower(getContextType(rptgen_sl.appdata_sl,c,false))
    case 'annotation'
        context=getString(message('RptgenSL:rsl_CAnnotationLoop:currentAnnotationLabel'));
    case 'model'
        context=getString(message('RptgenSL:rsl_CAnnotationLoop:reportedSystemsAnnotationsLabel'));
    case 'system';
        context=getString(message('RptgenSL:rsl_CAnnotationLoop:currentSystemAnnotationsLabel'));
    case 'signal'
        context=getString(message('RptgenSL:rsl_CAnnotationLoop:noneLabel'));
    case 'block'
        context=getString(message('RptgenSL:rsl_CAnnotationLoop:noneLabel'));
    otherwise
        context=getString(message('RptgenSL:rsl_CAnnotationLoop:allAnnotationsLabel'));
    end
