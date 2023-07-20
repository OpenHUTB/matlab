function cs=loop_getContextString(c)






    currContext=getContextType(rptgen_sf.appdata_sf,c,logical(0));

    switch lower(currContext)
    case{'machine','state','chart'}
        cs=sprintf(getString(message('RptgenSL:rsf_csf_hier_loop:allObjectsLabel')),currContext);
    case 'object'
        cs=getString(message('RptgenSL:rsf_csf_hier_loop:currentObjectLabel'));
    otherwise

        cs=getString(message('RptgenSL:rsf_csf_hier_loop:allObjectsInSLContextLabel'));
    end
