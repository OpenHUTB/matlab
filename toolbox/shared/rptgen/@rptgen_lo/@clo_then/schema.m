function schema






    pkgLO=findpackage('rptgen_lo');

    h=schema.class(pkgLO,'clo_then',pkgLO.findclass('rpt_if_comp'));


    rptgen.makeStaticMethods(h,{
    },{
    });