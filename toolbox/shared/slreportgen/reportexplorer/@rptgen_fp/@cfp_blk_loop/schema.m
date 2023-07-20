function schema






    pkgFP=findpackage('rptgen_fp');
    pkgSL=findpackage('rptgen_sl');

    h=schema.class(pkgFP,'cfp_blk_loop',pkgSL.findclass('csl_blk_loop'));


    rptgen.makeStaticMethods(h,{
    },{
'loop_getLoopObjects'
'loop_getObjectType'
'loop_getPropSrc'
    });