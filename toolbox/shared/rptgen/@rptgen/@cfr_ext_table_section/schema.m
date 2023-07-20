function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'cfr_ext_table_section',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'StyleName','ustring','',...
    getString(message('rptgen:rptgen:styleNameLabel')));


    rptgen.prop(h,'VertAlign',rptgen.enumTableVertAlign,'top',...
    getString(message('rptgen:r_cfr_ext_table_section:vertAlignLabel')));


    rptgen.makeStaticMethods(h,{
    },{

    });