function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'cfr_ext_table_row',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'VertAlign',rptgen.enumTableVertAlignInherit,'inherit',...
    getString(message('rptgen:r_cfr_ext_table_row:vertAlignLabel')));


    rptgen.prop(h,'RowSep',rptgen.enumTrueFalseInherit,'inherit',getString(message('rptgen:r_cfr_ext_table_row:rowSepLabel')));


    rptgen.prop(h,'BackgroundColor','ustring','auto',...
    getString(message('rptgen:r_cfr_ext_table_row:backgroundColorLabel')));


    rptgen.makeProp(h,'RowHeightType',{
    'auto',getString(message('rptgen:r_cfr_ext_table:autoTableWidthLabel'))
    'specify',getString(message('rptgen:r_cfr_ext_table:specifyTableWidthLabel'))
    },'auto','');


    rptgen.prop(h,'RowHeight','ustring','12pt',getString(message('rptgen:r_cfr_ext_table_row:rowHeightLabel')));


    rptgen.prop(h,'TextOrientation','ustring','auto',getString(message('rptgen:r_cfr_ext_table_row:textOrientationLabel')));


    rptgen.prop(h,'RotatedTextWidth','ustring','.5in',getString(message('rptgen:r_cfr_ext_table_row:rotatedTextWidthLabel')));


    rptgen.makeStaticMethods(h,{
    },{
    });
