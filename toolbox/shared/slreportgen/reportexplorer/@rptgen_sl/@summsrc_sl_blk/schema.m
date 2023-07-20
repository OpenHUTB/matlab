function schema




    pkgRG=findpackage('rptgen');
    pkgSL=findpackage('rptgen_sl');

    h=schema.class(pkgSL,...
    'summsrc_sl_blk',...
    pkgRG.findclass('summsrc'));