function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'cfr_ext_table_entry',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'HorizAlign',rptgen.enumTableHorizAlignInherit,'inherit',...
    getString(message('rptgen:r_cfr_ext_table_entry:horizAlignLabel')));



    rptgen.prop(h,'VertAlign',rptgen.enumTableVertAlignInherit,'inherit',...
    getString(message('rptgen:r_cfr_ext_table_entry:vertAlignLabel')));


    rptgen.prop(h,'RowSep',rptgen.enumTrueFalseInherit,'inherit',getString(message('rptgen:r_cfr_ext_table_entry:rowSepLabel')));


    rptgen.prop(h,'ColSep',rptgen.enumTrueFalseInherit,'inherit',getString(message('rptgen:r_cfr_ext_table_entry:colSepLabel')));


    rptgen.prop(h,'Color','ustring','auto',...
    getString(message('rptgen:r_cfr_ext_table_entry:backgroundColorLabel')));


    rptgen.prop(h,'SpanStartCol','ustring','',...
    getString(message('rptgen:r_cfr_ext_table_entry:spanStartColLabel')));


    rptgen.prop(h,'SpanEndCol','ustring','',...
    getString(message('rptgen:r_cfr_ext_table_entry:spanEndColLabel')));


    rptgen.prop(h,'SpanNumRows','ustring','1',...
    getString(message('rptgen:r_cfr_ext_table_entry:spanNumRowsLabel')));


    rptgen.prop(h,'TextOrientation','ustring','auto',getString(message('rptgen:r_cfr_ext_table_row:textOrientationLabel')));


    rptgen.prop(h,'RotatedTextWidth','ustring','.5in',getString(message('rptgen:r_cfr_ext_table_row:rotatedTextWidthLabel')));



    rptgen.makeStaticMethods(h,{
    },{
    });
