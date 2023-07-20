function schema






    pkgUD=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgUD,'udd_loop',pkgRG.findclass('rpt_looper'));


    rptgen.makeStaticMethods(h,{
    },{
'loop_restoreState'
'loop_setState'
'loop_saveState'
    });