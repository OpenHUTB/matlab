function schema




    pkgUD=findpackage('rptgen_ud');
    pkgSF=findpackage('rptgen_sf');

    h=schema.class(pkgSF,'propsrc_sf',...
    pkgUD.findclass('propsrc_ud'));
