function schema






    pkgLO=findpackage('rptgen_lo');

    h=schema.class(pkgLO,'clo_else_if',pkgLO.findclass('clo_if'));


    rptgen.makeStaticMethods(h,{
    },{
    });