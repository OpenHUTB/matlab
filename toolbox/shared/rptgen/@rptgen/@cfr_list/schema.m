function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cfr_list',pkgRG.findclass('rpt_list'));


    rptgen.prop(h,'Source','MATLAB array','','');


    rptgen.makeStaticMethods(h,{
    },{
'list_getContent'
    });