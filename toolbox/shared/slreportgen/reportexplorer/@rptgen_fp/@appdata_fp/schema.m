function schema





    mlock;

    pkg=findpackage('rptgen_fp');
    pkgRG=findpackage('rptgen');

    schema.class(pkg,'appdata_fp',pkgRG.findclass('appdata'));

