function schema






    pkgRMI=findpackage('RptgenRMI');
    pkgSL=findpackage('rptgen_sl');

    h=schema.class(pkgRMI,'NoReqSystemLoop',pkgSL.findclass('csl_sys_loop'));


    rptgen.makeStaticMethods(h,{
    },{
'loop_getLoopObjects'
    });