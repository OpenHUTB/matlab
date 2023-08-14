function schema





    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'cfr_ext_table_colspec',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'ColName','ustring','c1',...
    getString(message('rptgen:r_cfr_ext_table_colspec:colNameLabel')));


    rptgen.prop(h,'ColNum','ustring','1',...
    getString(message('rptgen:r_cfr_ext_table_colspec:colNumLabel')));


    rptgen.prop(h,'ColWidth','ustring','1*',...
    getString(message('rptgen:r_cfr_ext_table_colspec:colWidthLabel')));


    rptgen.prop(h,'HorizAlign',rptgen.enumTableHorizAlignInherit,'inherit',...
    getString(message('rptgen:r_cfr_ext_table_colspec:horizAlignLabel')));


    rptgen.prop(h,'RowSep',rptgen.enumTrueFalseInherit,'inherit',getString(message('rptgen:r_cfr_ext_table_colspec:rowSepLabel')));


    rptgen.prop(h,'ColSep',rptgen.enumTrueFalseInherit,'inherit',getString(message('rptgen:r_cfr_ext_table_colspec:colSepLabel')));



    rptgen.makeStaticMethods(h,{
    },{
    });



