function s=getOutlineString(c)







    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsf_csf_count:unlicensedComponentLabel'));
        return;

    end

    ct=getContextType(rptgen_sf.appdata_sf,c,true);
    if strcmpi(ct,'Object')
        ct=getString(message('RptgenSL:rsf_csf_count:currentObjectLabel'));
    elseif strcmp(c.CountDepth,'shallow')
        ct=sprintf(getString(message('RptgenSL:rsf_csf_count:childrenOfLabel')),lower(ct));
    else
        ct=sprintf(getString(message('RptgenSL:rsf_csf_count:allObjectsInLabel')),lower(ct));
    end

    s=sprintf(getString(message('RptgenSL:rsf_csf_count:countMsg')),ct);
