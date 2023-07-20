function schema






    pkgRMI=findpackage('RptgenRMI');
    pkgSL=findpackage('rptgen_sl');

    h=schema.class(pkgRMI,'NoReqBlockLoop',pkgSL.findclass('csl_blk_loop'));


    rptgen.makeStaticMethods(h,{
    },{
'loop_getLoopObjects'
    });