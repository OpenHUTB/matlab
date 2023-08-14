function schema






    pkg=findpackage('RptSldv');
    pkgSF=findpackage('rptgen_sf');

    h=schema.class(pkg,'SfLinkChartLoop',pkgSF.findclass('csf_chart_loop'));







    rptgen.makeStaticMethods(h,{
    },{
'loop_getLoopObjects'
'loop_saveState'
'loop_setState'
    });
