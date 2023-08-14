function schema




    mlock;

    pkg=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'propsrc_hg',pkgRG.findclass('propsrc'));
