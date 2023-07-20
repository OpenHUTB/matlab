function iTitle=gr_getTitle(c,fName,id,varargin)%#ok









    switch c.TitleType
    case 'none'
        iTitle='';
    case 'objname'
        psSF=rptgen_sf.propsrc_sf;
        iTitle=getObjectName(psSF,id);
    case 'fullsfname'
        psSF=rptgen_sf.propsrc_sf;
        d=get(rptgen.appdata_rg,'CurrentDocument');
        iTitle=getSFPath(psSF,id,d);
    case 'fullslsfname'
        psSF=rptgen_sf.propsrc_sf;
        d=get(rptgen.appdata_rg,'CurrentDocument');
        iTitle=getSLSFPath(psSF,id,d);
    case 'manual'
        iTitle=rptgen.parseExpressionText(c.Title);
    end


