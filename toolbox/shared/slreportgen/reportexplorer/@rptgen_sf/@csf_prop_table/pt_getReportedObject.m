function obj=pt_getReportedObject(this)









    obj=get(rptgen_sf.appdata_sf,'CurrentObject');
    if~ishandle(obj)
        error(message('RptgenSL:rsf_csf_prop_table:noCurrentSFObjectLabel'));
    end
