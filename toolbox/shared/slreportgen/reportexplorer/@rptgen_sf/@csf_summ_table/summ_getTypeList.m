function allTypes=summ_getTypeList







    allTypes=listReportableTypes(rptgen_sf.appdata_sf);
    allTypes=allTypes(:);
    allTypes=[allTypes,allTypes];
