function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'cfr_table',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'TableTitle','ustring','',getString(message('rptgen:r_cfr_table:tableTitleLabel')));


    rptgen.prop(h,'Source','MATLAB array','',getString(message('rptgen:r_cfr_table:workspaceVariableNameLabel')));



    rptgen.prop(h,'isPgwide','bool',true,getString(message('rptgen:r_cfr_table:tableSpansPageLabel')));


    rptgen.prop(h,'ColumnWidths','MATLAB array',[],getString(message('rptgen:r_cfr_table:colWidthsLabel')));




    rptgen.prop(h,'AllAlign',rptgen.enumTableHorizAlign,'left',...
    getString(message('rptgen:r_cfr_table:cellAlignLabel')));


    rptgen.prop(h,'isBorder','bool',true,getString(message('rptgen:r_cfr_table:isBorderLabel')));


    p=rptgen.prop(h,'isInverted','bool',false,...
    getString(message('rptgen:r_cfr_table:rotate90Label')));
    p.Visible='off';



    rptgen.prop(h,'numHeaderRowsString','ustring','1',getString(message('rptgen:r_cfr_table:numHeaderRowsLabel')));
    p=rptgen.prop(h,'numHeaderRows','int32',1,'');
    p.GetFunction=@getNumHeaderRows;
    p.SetFunction=@setNumHeaderRows;
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.Visible='off';


    rptgen.prop(h,'Footer',{
    'NONE',getString(message('rptgen:r_cfr_table:noFooterLabel'))
    'LASTROWS',getString(message('rptgen:r_cfr_table:footerIsLastRowsLabel'))
    },'NONE','');



    rptgen.prop(h,'numFooterRowsString','ustring','1','');
    p=rptgen.prop(h,'numFooterRows','int32',1,'');
    p.GetFunction=@getNumFooterRows;
    p.SetFunction=@setNumFooterRows;
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.Visible='off';



    rptgen.prop(h,'ShrinkEntries','bool',true,...
    getString(message('rptgen:r_cfr_table:collapseCellsLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'getContent'
    });
