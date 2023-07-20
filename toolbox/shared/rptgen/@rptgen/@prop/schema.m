function schema




    mlock;

    pkg=findpackage('rptgen');
    pkgSchema=findpackage('schema');

    h=schema.class(pkg,'prop',pkgSchema.findclass('prop'));

