function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cfr_page_break',pkgRG.findclass('rptcomponent'));


    rptgen.makeStaticMethods(h,{},{});
