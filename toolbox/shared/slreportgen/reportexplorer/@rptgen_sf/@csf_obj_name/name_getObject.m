function o=name_getObject(c)




    o=get(rptgen_sf.appdata_sf,'CurrentObject');
    if~ishandle(o)
        o=[];
    end
